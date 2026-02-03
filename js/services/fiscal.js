/**
 * Sistema de Emissão Fiscal - NFC-e e NF-e
 * Desacoplado do PDV - pode ser emitido em qualquer momento
 */

class FiscalSystem {
    /**
     * Inicializar sistema fiscal
     */
    static async init() {
        this.setupEventos();
    }

    /**
     * Emitir NFC-e (Nota Fiscal do Consumidor Eletrônica)
     * Fluxo: Venda finalizada → Emissão NFC-e → Atualizar status
     */
    static async emitirNFCe(vendaId, tentativa = 1) {
        try {
            const maxTentativas = 3;
            const delayRetry = tentativa * 5000; // 5s, 10s, 15s

            // Buscar venda
            const { data: venda, error: erroV } = await supabase
                .from('vendas')
                .select('*, vendas_itens(*), clientes(*)')
                .eq('id', vendaId)
                .single();

            if (erroV) throw new Error('Venda não encontrada');

            // Verificar se já foi emitida
            if (venda.status_fiscal !== 'SEM_DOCUMENTO_FISCAL' && venda.status_fiscal !== 'REJEITADA_SEFAZ') {
                throw new Error('NFC-e já foi emitida para esta venda');
            }

            // Atualizar status para "pendente"
            await supabase
                .from('vendas')
                .update({ status_fiscal: 'PENDENTE_EMISSAO' })
                .eq('id', vendaId);

            // Montar XML da NFC-e
            const xml = await this.montarXmlNFCe(venda);

            // Enviar para Focus NFe via Edge Function
            const { data: resultado, error: erroEmissao } = await supabase.functions
                .invoke('emitir-nfce', {
                    body: {
                        xml: xml,
                        vendor_id: venda.id
                    }
                });

            if (erroEmissao) {
                if (tentativa < maxTentativas) {
                    console.log(`Tentativa ${tentativa}/${maxTentativas} falhou. Aguardando ${delayRetry}ms...`);
                    setTimeout(() => this.emitirNFCe(vendaId, tentativa + 1), delayRetry);
                    return;
                } else {
                    throw new Error('Máximo de tentativas atingido');
                }
            }

            // Atualizar venda com dados da NFC-e
            if (resultado.status === 'autorizada') {
                await supabase
                    .from('vendas')
                    .update({
                        status_fiscal: 'EMITIDA_NFCE',
                        numero_nfce: resultado.numero,
                        chave_acesso_nfce: resultado.chave,
                        protocolo_nfce: resultado.protocolo,
                        xml_nfce: xml
                    })
                    .eq('id', vendaId);

                // Registrar documento fiscal
                await this.registrarDocumentoFiscal(vendaId, 'NFCE', resultado);

                return {
                    sucesso: true,
                    numero: resultado.numero,
                    chave: resultado.chave,
                    protocolo: resultado.protocolo
                };
            } else if (resultado.status === 'rejeitada') {
                await supabase
                    .from('vendas')
                    .update({
                        status_fiscal: 'REJEITADA_SEFAZ',
                        mensagem_erro_fiscal: resultado.mensagem
                    })
                    .eq('id', vendaId);

                throw new Error('NFC-e rejeitada SEFAZ: ' + resultado.mensagem);
            }
        } catch (error) {
            console.error('Erro ao emitir NFC-e:', error);
            
            // Atualizar status para rejeitada
            await supabase
                .from('vendas')
                .update({
                    status_fiscal: 'REJEITADA_SEFAZ',
                    mensagem_erro_fiscal: error.message
                })
                .eq('id', vendaId);

            return {
                sucesso: false,
                erro: error.message
            };
        }
    }

    /**
     * Emitir NF-e (Nota Fiscal Eletrônica) para B2B
     */
    static async emitirNFe(vendaId) {
        try {
            // Verificar se venda é para cliente PJ
            const { data: venda, error: erroV } = await supabase
                .from('vendas')
                .select('*, vendas_itens(*), clientes(*)')
                .eq('id', vendaId)
                .single();

            if (erroV) throw new Error('Venda não encontrada');

            if (!venda.cliente_id || venda.clientes.tipo !== 'PJ') {
                throw new Error('NF-e apenas para clientes PJ');
            }

            // Atualizar status
            await supabase
                .from('vendas')
                .update({ status_fiscal: 'PENDENTE_EMISSAO' })
                .eq('id', vendaId);

            // Montar XML da NF-e
            const xml = await this.montarXmlNFe(venda);

            // Enviar para Focus NFe
            const { data: resultado, error: erroEmissao } = await supabase.functions
                .invoke('emitir-nfe', {
                    body: {
                        xml: xml,
                        vendor_id: venda.id
                    }
                });

            if (erroEmissao) throw erroEmissao;

            // Atualizar venda
            await supabase
                .from('vendas')
                .update({
                    status_fiscal: 'EMITIDA_NFE',
                    numero_nfe: resultado.numero,
                    chave_acesso_nfe: resultado.chave,
                    protocolo_nfe: resultado.protocolo,
                    xml_nfe: xml
                })
                .eq('id', vendaId);

            // Registrar documento fiscal
            await this.registrarDocumentoFiscal(vendaId, 'NFE', resultado);

            return {
                sucesso: true,
                numero: resultado.numero,
                chave: resultado.chave,
                protocolo: resultado.protocolo
            };
        } catch (error) {
            console.error('Erro ao emitir NF-e:', error);
            return {
                sucesso: false,
                erro: error.message
            };
        }
    }

    /**
     * Consultar status de documento fiscal
     */
    static async consultarDocumentoFiscal(vendaId) {
        try {
            const { data: venda, error: erroV } = await supabase
                .from('vendas')
                .select('*')
                .eq('id', vendaId)
                .single();

            if (erroV) throw erroV;

            const tipo = venda.numero_nfce ? 'NFCE' : 'NFE';
            const chave = venda.numero_nfce ? venda.chave_acesso_nfce : venda.chave_acesso_nfe;

            if (!chave) {
                return { status: 'nao_emitida', mensagem: 'Documento ainda não foi emitido' };
            }

            // Consultar via Edge Function
            const { data: resultado, error: erroConsulta } = await supabase.functions
                .invoke('consultar-nf', {
                    body: {
                        chave: chave,
                        tipo: tipo
                    }
                });

            if (erroConsulta) throw erroConsulta;

            return resultado;
        } catch (error) {
            console.error('Erro ao consultar documento:', error);
            return {
                status: 'erro',
                mensagem: error.message
            };
        }
    }

    /**
     * Cancelar documento fiscal
     */
    static async cancelarDocumentoFiscal(vendaId, motivo) {
        try {
            const { data: venda, error: erroV } = await supabase
                .from('vendas')
                .select('*')
                .eq('id', vendaId)
                .single();

            if (erroV) throw erroV;

            const tipo = venda.numero_nfce ? 'NFCE' : 'NFE';
            const chave = venda.numero_nfce ? venda.chave_acesso_nfce : venda.chave_acesso_nfe;

            if (!chave) throw new Error('Nenhum documento para cancelar');

            // Cancelar via Edge Function
            const { data: resultado, error: erroCancelamento } = await supabase.functions
                .invoke('cancelar-nf', {
                    body: {
                        chave: chave,
                        motivo: motivo,
                        tipo: tipo
                    }
                });

            if (erroCancelamento) throw erroCancelamento;

            // Atualizar venda
            await supabase
                .from('vendas')
                .update({
                    status_fiscal: 'CANCELADA',
                    status_venda: 'CANCELADA'
                })
                .eq('id', vendaId);

            return {
                sucesso: true,
                protocolo: resultado.protocolo
            };
        } catch (error) {
            console.error('Erro ao cancelar documento:', error);
            return {
                sucesso: false,
                erro: error.message
            };
        }
    }

    /**
     * Montar XML NFC-e
     */
    static async montarXmlNFCe(venda) {
        const empresa = await this.obterEmpresa();
        const cliente = venda.clientes || {};

        let itensXml = '';
        venda.vendas_itens.forEach((item, idx) => {
            itensXml += `
            <det nItem="${idx + 1}">
                <prod>
                    <code>${item.sku || item.produto_id}</code>
                    <xProd>${item.nome}</xProd>
                    <NCM>22021000</NCM>
                    <CFOP>5102</CFOP>
                    <uCom>UN</uCom>
                    <qCom>${item.quantidade}</qCom>
                    <vUnCom>${item.preco_unitario}</vUnCom>
                    <vItem>${item.total}</vItem>
                </prod>
            </det>`;
        });

        const xml = `<?xml version="1.0" encoding="UTF-8"?>
<nfce>
    <infNFe versao="4.00">
        <ide>
            <cUF>${this.obterCodigoEstado(empresa.estado)}</cUF>
            <natOp>VENDA</natOp>
            <mod>65</mod>
            <serie>${empresa.nfce_serie}</serie>
            <nNF>${empresa.nfce_numero}</nNF>
            <dEmi>${new Date().toISOString().split('T')[0].replace(/-/g, '')}</dEmi>
            <hEmi>${new Date().toISOString().split('T')[1].substring(0, 8).replace(/:/g, '')}</hEmi>
            <indFinal>1</indFinal>
            <indPres>1</indPres>
            <idDest>1</idDest>
            <cMunFG>${empresa.codigo_municipio}</cMunFG>
            <tpEmis>1</tpEmis>
            <cDV>0</cDV>
            <tpAmb>${empresa.nfe_ambiente}</tpAmb>
            <finNFe>1</finNFe>
            <indIntermed>0</indIntermed>
            <procEmi>0</procEmi>
            <verProc>4.0</verProc>
        </ide>
        
        <emit>
            <CNPJ>${empresa.cnpj.replace(/\D/g, '')}</CNPJ>
            <xNome>${empresa.nome_empresa}</xNome>
            <xFant>${empresa.nome_empresa}</xFant>
            <enderEmit>
                <xLgr>${empresa.logradouro}</xLgr>
                <nro>${empresa.numero}</nro>
                <xBairro>${empresa.bairro}</xBairro>
                <cMun>${empresa.codigo_municipio}</cMun>
                <UF>${empresa.estado}</UF>
                <CEP>${empresa.cep.replace(/\D/g, '')}</CEP>
            </enderEmit>
            <IE>${empresa.inscricao_estadual}</IE>
            <IM>${empresa.inscricao_municipal || '0'}</IM>
            <CNAE>${empresa.cnae || '4723700'}</CNAE>
            <CRT>${empresa.regime_tributario}</CRT>
        </emit>
        
        <dest>
            ${cliente.cpf_cnpj ? `<${cliente.tipo === 'PJ' ? 'CNPJ' : 'CPF'}>${cliente.cpf_cnpj.replace(/\D/g, '')}</${cliente.tipo === 'PJ' ? 'CNPJ' : 'CPF'}>` : '<CNPJ>16716114000172</CNPJ>'}
            <xNome>${cliente.nome || 'CONSUMIDOR'}</xNome>
            ${cliente.endereco ? `<enderDest>
                <xLgr>${cliente.endereco}</xLgr>
                <nro>${cliente.numero || '0'}</nro>
                <xBairro>${cliente.bairro || 'SN'}</xBairro>
                <cMun>${this.obterCodigoMunicipio(cliente.cidade, cliente.estado)}</cMun>
                <UF>${cliente.estado || empresa.estado}</UF>
            </enderDest>` : ''}
        </dest>
        
        <det>
            ${itensXml}
        </det>
        
        <total>
            <ICMSTot>
                <vBC>0.00</vBC>
                <vICMS>0.00</vICMS>
                <vICMSDeson>0.00</vICMSDeson>
                <vFCP>0.00</vFCP>
                <vBCST>0.00</vBCST>
                <vST>0.00</vST>
                <vFCPST>0.00</vFCPST>
                <vFCPSTRet>0.00</vFCPSTRet>
                <vProd>${venda.subtotal}</vProd>
                <vFrete>0.00</vFrete>
                <vSeg>0.00</vSeg>
                <vDesc>${venda.desconto}</vDesc>
                <vII>0.00</vII>
                <vIPI>0.00</vIPI>
                <vIPIDevol>0.00</vIPIDevol>
                <vPIS>0.00</vPIS>
                <vCOFINS>0.00</vCOFINS>
                <vOutro>0.00</vOutro>
                <vNF>${venda.total}</vNF>
            </ICMSTot>
        </total>
        
        <pag>
            <detPag>
                <tPag>${this.mapearFormaPagamento(venda.forma_pagamento)}</tPag>
                <vPag>${venda.total}</vPag>
            </detPag>
        </pag>
        
        <infAdic>
            <infCpl>Venda via PDV. NFC-e gerada automaticamente.</infCpl>
        </infAdic>
    </infNFe>
</nfce>`;

        return xml;
    }

    /**
     * Montar XML NF-e
     */
    static async montarXmlNFe(venda) {
        // Similar ao NFC-e, mas com campos específicos para B2B
        return await this.montarXmlNFCe(venda);
    }

    /**
     * Registrar documento fiscal
     */
    static async registrarDocumentoFiscal(vendaId, tipo, resultado) {
        try {
            await supabase
                .from('documentos_fiscais')
                .insert({
                    venda_id: vendaId,
                    tipo_documento: tipo,
                    numero_documento: resultado.numero,
                    serie: resultado.serie,
                    chave_acesso: resultado.chave,
                    protocolo_autorizacao: resultado.protocolo,
                    status_sefaz: 'AUTORIZADA',
                    data_autorizacao: new Date().toISOString()
                });
        } catch (error) {
            console.error('Erro ao registrar documento:', error);
        }
    }

    /**
     * Obter empresa
     */
    static async obterEmpresa() {
        const { data } = await supabase.from('empresa_config').select('*').single();
        return data || {};
    }

    /**
     * Mapear forma de pagamento para código SEFAZ
     */
    static mapearFormaPagamento(forma) {
        const mapa = {
            'DINHEIRO': '01',
            'CARTAO_CREDITO': '02',
            'CARTAO_DEBITO': '03',
            'PIX': '26',
            'CHEQUE': '04',
            'PRAZO': '05',
            'VALE': '07'
        };
        return mapa[forma] || '01';
    }

    /**
     * Obter código de estado
     */
    static obterCodigoEstado(estado) {
        const mapa = {
            'AC': '24', 'AL': '17', 'AP': '16', 'AM': '03', 'BA': '05',
            'CE': '07', 'DF': '26', 'ES': '32', 'GO': '52', 'MA': '11',
            'MT': '28', 'MS': '50', 'MG': '31', 'PA': '15', 'PB': '21',
            'PR': '41', 'PE': '25', 'PI': '22', 'RJ': '33', 'RN': '24',
            'RS': '43', 'RO': '23', 'RR': '24', 'SC': '42', 'SP': '35',
            'SE': '28', 'TO': '29'
        };
        return mapa[estado] || '35';
    }

    /**
     * Setup de eventos
     */
    static setupEventos() {
        // Eventos de emissão fiscal
    }

    /**
     * Obter código município (placeholder)
     */
    static obterCodigoMunicipio(cidade, estado) {
        return '3550308'; // São Paulo padrão
    }
}

// Inicializar
document.addEventListener('DOMContentLoaded', () => FiscalSystem.init());
