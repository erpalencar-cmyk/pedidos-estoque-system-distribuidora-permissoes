/**
 * Serviço de Integração com API Nuvem Fiscal
 * Documentação: https://dev.nuvemfiscal.com.br/docs/api/
 * 
 * Funcionalidades:
 * - Emissão, consulta e cancelamento de NFC-e
 * - Download de PDF (DANFCE) e XML
 * - Consulta de CEP (endereços)
 * - Consulta de CNPJ (dados cadastrais de empresas)
 * - Consulta de status SEFAZ
 */

class NuvemFiscalService {
    constructor() {
        this.baseURL = 'https://api.nuvemfiscal.com.br';
        this.authURL = 'https://auth.nuvemfiscal.com.br';
        this.clientId = null;
        this.clientSecret = null;
        this.accessToken = null;
        this.tokenExpiry = null;
        this.ambiente = 'homologacao'; // 'homologacao' ou 'producao'
    }

    /**
     * Carregar configuração da empresa do banco de dados
     */
    async carregarConfig() {
        try {
            const { data: config, error } = await supabase
                .from('empresa_config')
                .select('nuvemfiscal_client_id, nuvemfiscal_client_secret, nuvemfiscal_access_token, nuvemfiscal_token_expiry, focusnfe_ambiente, cnpj')
                .single();

            if (error) throw error;

            this.clientId = config.nuvemfiscal_client_id;
            this.clientSecret = config.nuvemfiscal_client_secret;
            this.accessToken = config.nuvemfiscal_access_token;
            this.tokenExpiry = config.nuvemfiscal_token_expiry ? new Date(config.nuvemfiscal_token_expiry) : null;
            
            // Converter tpAmb (1=produção, 2=homologação) para string ambiente
            const tpAmb = config.focusnfe_ambiente || 2;
            this.ambiente = tpAmb === 1 ? 'producao' : 'homologacao';

            if (!this.clientId || !this.clientSecret) {
                throw new Error('Credenciais da Nuvem Fiscal não configuradas. Acesse Configurações da Empresa.');
            }

            return config;
        } catch (erro) {
            console.error('Erro ao carregar configuração:', erro);
            throw erro;
        }
    }

    /**
     * Obter access token OAuth2
     * Usa token em cache se válido, caso contrário requisita novo
     */
    async getAccessToken() {
        try {
            // Verificar se há token em cache válido
            if (this.accessToken && this.tokenExpiry && new Date() < this.tokenExpiry) {
                return this.accessToken;
            }

            // Carregar credenciais se não estiverem carregadas
            if (!this.clientId || !this.clientSecret) {
                await this.carregarConfig();
            }

            // Requisitar novo token OAuth2
            // Documentação: https://dev.nuvemfiscal.com.br/docs/autenticacao/
            const scopes = 'empresa cep cnpj nfe nfce nfse cte mdfe';
            const params = new URLSearchParams({
                grant_type: 'client_credentials',
                client_id: this.clientId,
                client_secret: this.clientSecret,
                scope: scopes
            });

            const response = await fetch(`${this.authURL}/oauth/token`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: params.toString()
            });

            if (!response.ok) {
                const errorText = await response.text();
                throw new Error(`Erro ao obter token OAuth2: ${response.status} - ${errorText}`);
            }

            const tokenData = await response.json();
            
            // Armazenar token e expiry
            this.accessToken = tokenData.access_token;
            
            // Calcular data de expiração (expires_in vem em segundos)
            const expiresInMs = tokenData.expires_in * 1000;
            this.tokenExpiry = new Date(Date.now() + expiresInMs);

            // Salvar token em cache no banco de dados
            await this.salvarTokenCache();

            return this.accessToken;

        } catch (erro) {
            console.error('Erro ao obter access token OAuth2:', erro);
            throw erro;
        }
    }

    /**
     * Salvar token em cache no banco de dados
     */
    async salvarTokenCache() {
        try {
            // Buscar o ID da empresa_config
            const { data: config } = await supabase
                .from('empresa_config')
                .select('id')
                .single();

            if (!config) return;

            const { error } = await supabase
                .from('empresa_config')
                .update({
                    nuvemfiscal_access_token: this.accessToken,
                    nuvemfiscal_token_expiry: this.tokenExpiry.toISOString()
                })
                .eq('id', config.id);

            if (error) {
                console.error('Erro ao salvar token em cache:', error);
            }
        } catch (erro) {
            console.error('Erro ao salvar token em cache:', erro);
        }
    }

    /**
     * Fazer requisição HTTP para a API
     */
    async request(endpoint, method = 'GET', body = null, headers = {}) {
        try {
            // Obter access token válido (usa cache ou requisita novo)
            const token = await this.getAccessToken();

            const url = `${this.baseURL}${endpoint}`;
            const options = {
                method,
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    ...headers
                }
            };

            if (body && method !== 'GET') {
                options.body = JSON.stringify(body);
                console.log('📤 [NuvemFiscal] Request:', { url, method, body });
            }

            const response = await fetch(url, options);
            
            // Para downloads de arquivos (PDF, XML)
            if (headers.Accept && headers.Accept !== 'application/json') {
                if (!response.ok) {
                    const errorText = await response.text();
                    throw new Error(`Erro ${response.status}: ${errorText}`);
                }
                return await response.blob();
            }

            const data = await response.json();
            
            console.log('📥 [NuvemFiscal] Response:', { status: response.status, data });

            if (!response.ok) {
                // Tentar extrair mensagens de erro detalhadas
                let mensagemErro = `Erro HTTP ${response.status}`;
                
                if (data.mensagens && Array.isArray(data.mensagens)) {
                    mensagemErro = data.mensagens.map(m => `[${m.codigo}] ${m.mensagem}`).join('; ');
                } else if (data.mensagem) {
                    mensagemErro = data.mensagem;
                } else if (data.erro) {
                    mensagemErro = data.erro;
                } else if (data.erros) {
                    mensagemErro = JSON.stringify(data.erros);
                }
                
                console.error('❌ [NuvemFiscal] Erro detalhado:', data);
                throw new Error(mensagemErro);
            }

            return data;
        } catch (erro) {
            console.error('❌ [NuvemFiscal] Erro na requisição:', erro);
            throw erro;
        }
    }

    // ===================================
    // MÉTODOS NFC-E
    // ===================================

    /**
     * Emitir NFC-e
     * POST /nfce
     * @param {Object} dadosNFCe - Dados completos da NFCe no formato da API
     * @returns {Object} Resposta da API com id, status, chave, etc
     */
    async emitirNFCe(dadosNFCe) {
        try {
            console.log('🚀 [NuvemFiscal] Estado ambiente antes:', { 
                ambiente: this.ambiente, 
                tipo: typeof this.ambiente 
            });
            
            // Adicionar ambiente aos dados (string: 'homologacao' ou 'producao')
            const payload = {
                ...dadosNFCe,
                ambiente: this.ambiente
            };
            
            console.log('🚀 [NuvemFiscal] Enviando NFC-e:', {
                ambiente: this.ambiente,
                tipo_ambiente: typeof this.ambiente,
                ambiente_payload: payload.ambiente,
                tpAmb: payload.infNFe?.ide?.tpAmb,
                cMunFG: payload.infNFe?.ide?.cMunFG,
                cMun: payload.infNFe?.emit?.enderEmit?.cMun
            });

            const resultado = await this.request('/nfce', 'POST', payload);

            // Se retornar status "pendente", aguardar processamento
            if (resultado.status === 'pendente') {
                return await this.aguardarProcessamento(resultado.id);
            }

            return resultado;
        } catch (erro) {
            console.error('Erro ao emitir NFC-e:', erro);
            throw erro;
        }
    }

    /**
     * Consultar NFC-e
     * GET /nfce/{id}
     * @param {string} id - ID da NFC-e retornado na emissão
     * @returns {Object} Status e dados completos da NFC-e com método para obter PDF
     */
    async consultarNFCe(id) {
        try {
            const resultado = await this.request(`/nfce/${id}`, 'GET');
            
            // Adicionar método para baixar PDF autenticado
            // O PDF da Nuvem Fiscal precisa do token Bearer
            if (resultado && resultado.id) {
                resultado.obterPDF = async () => {
                    const token = await this.getAccessToken();
                    const response = await fetch(`${this.baseURL}/nfce/${resultado.id}/pdf`, {
                        headers: {
                            'Authorization': `Bearer ${token}`,
                            'Accept': 'application/pdf'
                        }
                    });
                    
                    if (!response.ok) {
                        throw new Error(`Erro ao baixar PDF: ${response.status}`);
                    }
                    
                    const blob = await response.blob();
                    const url = URL.createObjectURL(blob);
                    return url;
                };
                
                // Para compatibilidade, adicionar flag indicando que precisa usar obterPDF()
                resultado.caminho_danfe = 'USE_OBTER_PDF_METHOD';
            }
            
            return resultado;
        } catch (erro) {
            console.error('Erro ao consultar NFC-e:', erro);
            throw erro;
        }
    }

    /**
     * Aguardar processamento assíncrono da NFC-e
     * Faz polling até status diferente de "pendente"
     */
    async aguardarProcessamento(id, maxTentativas = 30, intervalo = 2000) {
        for (let i = 0; i < maxTentativas; i++) {
            const resultado = await this.consultarNFCe(id);
            
            if (resultado.status !== 'pendente') {
                return resultado;
            }

            // Aguardar antes da próxima tentativa
            await new Promise(resolve => setTimeout(resolve, intervalo));
        }

        throw new Error('Timeout: NFC-e ainda está sendo processada após múltiplas tentativas');
    }

    /**
     * Cancelar NFC-e
     * POST /nfce/{id}/cancelamento
     * @param {string} id - ID da NFC-e
     * @param {string} justificativa - Motivo do cancelamento (min 15 caracteres)
     * @returns {Object} Resultado do cancelamento
     */
    async cancelarNFCe(id, justificativa) {
        try {
            if (!justificativa || justificativa.length < 15) {
                throw new Error('Justificativa deve ter no mínimo 15 caracteres');
            }

            const payload = {
                justificativa: justificativa
            };

            const resultado = await this.request(`/nfce/${id}/cancelamento`, 'POST', payload);

            // Se retornar status "pendente", aguardar processamento
            if (resultado.status === 'pendente') {
                return await this.aguardarProcessamento(resultado.id);
            }

            return resultado;
        } catch (erro) {
            console.error('Erro ao cancelar NFC-e:', erro);
            throw erro;
        }
    }

    /**
     * Baixar PDF da NFC-e (DANFCE)
     * GET /nfce/{id}/pdf
     * @param {string} id - ID da NFC-e
     * @returns {Blob} Arquivo PDF
     */
    async baixarPDF(id) {
        try {
            return await this.request(`/nfce/${id}/pdf`, 'GET', null, {
                'Accept': 'application/pdf'
            });
        } catch (erro) {
            console.error('Erro ao baixar PDF:', erro);
            throw erro;
        }
    }

    /**
     * Baixar XML da NFC-e
     * GET /nfce/{id}/xml
     * @param {string} id - ID da NFC-e
     * @returns {Blob} Arquivo XML
     */
    async baixarXML(id) {
        try {
            return await this.request(`/nfce/${id}/xml`, 'GET', null, {
                'Accept': 'application/xml'
            });
        } catch (erro) {
            console.error('Erro ao baixar XML:', erro);
            throw erro;
        }
    }

    /**
     * Consultar status do serviço SEFAZ
     * GET /nfce/sefaz/status
     * @param {string} cpfCnpj - CPF ou CNPJ da empresa
     * @param {string} uf - UF da empresa (opcional)
     * @returns {Object} Status do serviço
     */
    async consultarStatusSefaz(cpfCnpj, uf = null) {
        try {
            const cnpjLimpo = cpfCnpj.replace(/\D/g, '');
            let url = `/nfce/sefaz/status?cpf_cnpj=${cnpjLimpo}&ambiente=${this.ambiente}`;
            if (uf) {
                url += `&uf=${uf}`;
            }
            return await this.request(url, 'GET');
        } catch (erro) {
            console.error('Erro ao consultar status SEFAZ:', erro);
            throw erro;
        }
    }

    /**
     * Listar NFC-e emitidas
     * GET /nfce?cpf_cnpj={cpf_cnpj}&ambiente={ambiente}
     * @param {string} cpfCnpj - CPF ou CNPJ da empresa
     * @param {string} ambiente - 'homologacao' ou 'producao'
     * @param {number} top - Número máximo de registros (padrão: 10)
     * @returns {Object} Lista de NFC-e
     */
    async listarNFCe(cpfCnpj, ambiente = 'homologacao', top = 10, status = null) {
        try {
            const cnpjLimpo = cpfCnpj.replace(/\D/g, '');
            let url = `/nfce?cpf_cnpj=${cnpjLimpo}&ambiente=${ambiente}&$top=${top}&$orderby=data_emissao desc`;
            
            // Filtrar por status se especificado (ex: 'autorizado')
            if (status) {
                url += `&$filter=status eq '${status}'`;
            }
            
            console.log('📋 [NuvemFiscal] Listando NFC-e:', url);
            const resultado = await this.request(url, 'GET');
            console.log('📋 [NuvemFiscal] Resultado:', resultado);
            return resultado;
        } catch (erro) {
            console.error('Erro ao listar NFC-e:', erro);
            throw erro;
        }
    }

    /**
     * Configurar empresa para emissão de NFC-e
     * PUT /empresas/{cpf_cnpj}/nfce
     * Configura CRT, CSC e ambiente
     */
    async configurarEmpresa(cpfCnpj, config) {
        try {
            const cnpjLimpo = cpfCnpj.replace(/\D/g, '');
            
            const payload = {
                crt: String(config.crt), // Código de Regime Tributário como string
                id_csc: String(config.id_csc), // ID do CSC
                csc: String(config.csc), // Código de Segurança do Contribuinte
                ambiente: config.ambiente || this.ambiente
            };

            return await this.request(`/empresas/${cnpjLimpo}/nfce`, 'PUT', payload);
        } catch (erro) {
            console.error('Erro ao configurar empresa:', erro);
            throw erro;
        }
    }

    // ===================================
    // MÉTODOS DE CONSULTA
    // ===================================

    /**
     * Consultar CEP
     * GET /cep/{Cep}
     * @param {string} cep - CEP a consultar (com ou sem máscara)
     * @returns {Object} Dados do endereço
     */
    async consultarCEP(cep) {
        try {
            // Remover máscara do CEP
            const cepLimpo = cep.replace(/\D/g, '');

            if (cepLimpo.length !== 8) {
                throw new Error('CEP inválido');
            }

            const resultado = await this.request(`/cep/${cepLimpo}`, 'GET');
            
            // Retornar no formato padronizado
            return {
                cep: resultado.cep,
                logradouro: resultado.logradouro || '',
                complemento: resultado.complemento || '',
                bairro: resultado.bairro || '',
                cidade: resultado.municipio || '',
                uf: resultado.uf || '',
                codigo_ibge: resultado.codigo_ibge || '',
                tipo_logradouro: resultado.tipo_logradouro || ''
            };
        } catch (erro) {
            console.error('Erro ao consultar CEP:', erro);
            throw erro;
        }
    }

    /**
     * Consultar CNPJ
     * GET /cnpj/{Cnpj}
     * @param {string} cnpj - CNPJ a consultar (com ou sem máscara)
     * @returns {Object} Dados cadastrais da empresa
     */
    async consultarCNPJ(cnpj) {
        try {
            // Remover máscara do CNPJ
            const cnpjLimpo = cnpj.replace(/\D/g, '');

            if (cnpjLimpo.length !== 14) {
                throw new Error('CNPJ inválido');
            }

            const resultado = await this.request(`/cnpj/${cnpjLimpo}`, 'GET');

            // Retornar no formato padronizado
            return {
                cnpj: resultado.cnpj,
                razao_social: resultado.razao_social || '',
                nome_fantasia: resultado.nome_fantasia || '',
                situacao_cadastral: resultado.situacao_cadastral || '',
                data_situacao_cadastral: resultado.data_situacao_cadastral || '',
                cnae_principal: resultado.atividade_principal?.codigo || '',
                descricao_cnae: resultado.atividade_principal?.descricao || '',
                natureza_juridica: resultado.natureza_juridica?.codigo || '',
                descricao_natureza_juridica: resultado.natureza_juridica?.descricao || '',
                capital_social: resultado.capital_social || 0,
                porte: resultado.porte || '',
                data_abertura: resultado.data_inicio_atividade || '',
                
                // Endereço
                logradouro: resultado.endereco?.logradouro || '',
                numero: resultado.endereco?.numero || '',
                complemento: resultado.endereco?.complemento || '',
                bairro: resultado.endereco?.bairro || '',
                cep: resultado.endereco?.cep || '',
                cidade: resultado.endereco?.municipio || '',
                uf: resultado.endereco?.uf || '',
                
                // Contato
                telefone: resultado.telefones?.[0] || '',
                email: resultado.email || '',
                
                // Regime tributário
                simples_nacional: resultado.simples?.optante || false,
                simples_data_opcao: resultado.simples?.data_opcao || null,
                mei: resultado.mei?.optante || false,
                
                // Dados completos (caso precise acessar outros campos)
                dados_completos: resultado
            };
        } catch (erro) {
            console.error('Erro ao consultar CNPJ:', erro);
            throw erro;
        }
    }

    // ===================================
    // MÉTODOS AUXILIARES
    // ===================================

    /**
     * Obter código IBGE da UF a partir da sigla
     */
    obterCodigoUF(siglaUF) {
        const codigosUF = {
            'RO': 11, 'AC': 12, 'AM': 13, 'RR': 14, 'PA': 15, 'AP': 16, 'TO': 17,
            'MA': 21, 'PI': 22, 'CE': 23, 'RN': 24, 'PB': 25, 'PE': 26, 'AL': 27, 'SE': 28, 'BA': 29,
            'MG': 31, 'ES': 32, 'RJ': 33, 'SP': 35,
            'PR': 41, 'SC': 42, 'RS': 43,
            'MS': 50, 'MT': 51, 'GO': 52, 'DF': 53
        };
        return codigosUF[siglaUF?.toUpperCase()] || 35; // Default São Paulo
    }

    /**
     * Montar payload de NFC-e a partir dos dados da venda
     * @param {Object} venda - Dados da venda com itens e cliente
     * @param {Object} empresa - Dados da empresa emitente
     * @returns {Object} Payload formatado para API Nuvem Fiscal
     */
    async montarPayloadNFCe(venda, empresa) {
        try {
            console.log('📋 [NuvemFiscal] Dados recebidos:', { venda, empresa });
            
            // Buscar número da próxima nota
            // Primeiro tenta da tabela vendas
            const { data: ultimaNota } = await supabase
                .from('vendas')
                .select('numero_nfce')
                .not('numero_nfce', 'is', null)
                .order('numero_nfce', { ascending: false })
                .limit(1)
                .single();

            let proximoNumero = ultimaNota?.numero_nfce ? parseInt(ultimaNota.numero_nfce) + 1 : 1;
            
            // Verificar o último número AUTORIZADO na API da Nuvem Fiscal
            // Importante: ignorar notas rejeitadas/canceladas
            try {
                const cnpj = empresa.cnpj?.replace(/\D/g, '');
                console.log('🔍 [NuvemFiscal] Buscando últimas notas AUTORIZADAS - CNPJ:', cnpj, 'Ambiente:', this.ambiente);
                
                // Buscar apenas notas autorizadas (top=50 para ter margem)
                const ultimasNotas = await this.listarNFCe(cnpj, this.ambiente, 50, 'autorizado');
                console.log('🔍 [NuvemFiscal] Resposta listarNFCe:', ultimasNotas);
                
                if (ultimasNotas?.data && ultimasNotas.data.length > 0) {
                    const ultimoNumeroAPI = parseInt(ultimasNotas.data[0].numero);
                    console.log('🔍 [NuvemFiscal] Último número AUTORIZADO na API:', ultimoNumeroAPI, 'Próximo calculado local:', proximoNumero);
                    
                    if (ultimoNumeroAPI >= proximoNumero) {
                        proximoNumero = ultimoNumeroAPI + 1;
                        console.log('✅ [NuvemFiscal] Ajustado para próximo número:', proximoNumero);
                    }
                } else {
                    console.log('⚠️ [NuvemFiscal] Nenhuma nota AUTORIZADA encontrada na API');
                }
            } catch (erro) {
                console.warn('❌ [NuvemFiscal] Erro ao buscar último número da API:', erro);
            }
            
            console.log('📄 [NuvemFiscal] Próximo número NFC-e:', proximoNumero);
            
            // Garantir valores numéricos válidos
            const subtotal = parseFloat(venda.subtotal || venda.valor_produtos || 0);
            const desconto = parseFloat(venda.desconto || 0);
            const valorTotal = parseFloat(venda.valor_total || venda.total || subtotal - desconto);
            const troco = parseFloat(venda.troco || 0);
            
            console.log('💰 [NuvemFiscal] Valores calculados:', { subtotal, desconto, valorTotal, troco });
            
            // Validar e formatar código do município (7 dígitos obrigatório)
            console.log('🏙️ [NuvemFiscal] Dados municipio:', {
                codigo_municipio: empresa.codigo_municipio,
                codigo_ibge: empresa.codigo_ibge,
                cidade: empresa.cidade,
                uf: empresa.uf
            });
            
            let codigoMunicipio = String(empresa.codigo_municipio || empresa.codigo_ibge || '3550308'); // Default: São Paulo
            if (codigoMunicipio.length < 7) {
                codigoMunicipio = codigoMunicipio.padStart(7, '0');
            }
            console.log('🏙️ [NuvemFiscal] Código município formatado:', codigoMunicipio);

            // Montar itens
            const itens = venda.venda_itens.map((item, index) => ({
                numero_item: index + 1,
                codigo_produto: item.codigo_produto || String(item.produto_id),
                descricao: item.nome_produto,
                cfop: '5102', // Venda de mercadoria adquirida ou recebida de terceiros
                ncm: item.ncm || '00000000',
                unidade_comercial: item.unidade || 'UN',
                quantidade_comercial: item.quantidade,
                valor_unitario_comercial: item.preco_unitario,
                valor_bruto: item.subtotal,
                unidade_tributavel: item.unidade || 'UN',
                quantidade_tributavel: item.quantidade,
                valor_unitario_tributavel: item.preco_unitario,
                valor_desconto: item.desconto || 0,
                icms: {
                    situacao_tributaria: '102', // Tributada sem débito
                    origem: '0' // Nacional
                },
                pis: {
                    situacao_tributaria: '49' // Outras operações
                },
                cofins: {
                    situacao_tributaria: '49' // Outras operações
                }
            }));

            // Montar dados do destinatário (se houver cliente)
            let destinatario = null;
            if (venda.clientes) {
                destinatario = {
                    cpf_cnpj: venda.clientes.cpf_cnpj?.replace(/\D/g, ''),
                    nome_completo: venda.clientes.nome,
                    email: venda.clientes.email || null
                };

                if (venda.clientes.endereco || venda.clientes.logradouro) {
                    destinatario.endereco = {
                        logradouro: venda.clientes.logradouro || '',
                        numero: venda.clientes.numero || 'SN',
                        bairro: venda.clientes.bairro || '',
                        codigo_municipio: venda.clientes.codigo_ibge || empresa.codigo_municipio || empresa.codigo_ibge,
                        municipio: venda.clientes.cidade || empresa.cidade,
                        uf: venda.clientes.uf || empresa.uf || empresa.estado,
                        cep: venda.clientes.cep?.replace(/\D/g, '') || ''
                    };
                }
            }

            // A Nuvem Fiscal usa a estrutura XML da SEFAZ (infNFe, ide, emit, det, etc)
            // Diferente do FocusNFe que aceita formato simplificado
            const payload = {
                referencia: `VENDA-${venda.id || Date.now()}`,
                // ambiente será adicionado pelo método emitirNFCe
                
                infNFe: {
                    versao: '4.00',
                    ide: {
                        cUF: this.obterCodigoUF(empresa.uf || empresa.estado), // Código UF do emitente
                        natOp: 'VENDA', // Natureza da operação
                        mod: 65, // Modelo 65 = NFC-e
                        serie: parseInt(empresa.serie_nfce || '1'),
                        nNF: parseInt(proximoNumero),
                        dhEmi: new Date().toISOString(),
                        tpNF: 1, // 1=Saída
                        idDest: 1, // 1=Operação interna
                        cMunFG: codigoMunicipio,
                        tpImp: 4, // 4=DANFE NFC-e
                        tpEmis: 1, // 1=Emissão normal
                        tpAmb: this.ambiente === 'producao' ? 1 : 2, // 1=Produção, 2=Homologação
                        finNFe: 1, // 1=Normal
                        indFinal: 1, // 1=Consumidor final
                        indPres: venda.tipo_venda === 'online' ? 4 : 1, // 1=Presencial, 4=Internet
                        procEmi: 0, // 0=Emissão com aplicativo do contribuinte
                        verProc: '1.0'
                    },
                    emit: {
                        CNPJ: empresa.cnpj?.replace(/\D/g, ''),
                        xNome: empresa.razao_social,
                        xFant: empresa.nome_fantasia || empresa.razao_social,
                        enderEmit: {
                            xLgr: empresa.logradouro || '',
                            nro: empresa.numero || 'SN',
                            xBairro: empresa.bairro || '',
                            cMun: codigoMunicipio,
                            xMun: empresa.cidade || '',
                            UF: empresa.uf || empresa.estado,
                            CEP: empresa.cep?.replace(/\D/g, '') || ''
                        },
                        IE: empresa.inscricao_estadual?.replace(/\D/g, '') || 'ISENTO',
                        CRT: parseInt(empresa.regime_tributario_codigo || empresa.crt || '1')
                    },
                    det: itens.map((item, index) => {
                        let quantidade = parseFloat(item.quantidade || item.qCom || 1);
                        let precoUnitario = parseFloat(item.preco_unitario || item.vUnCom || item.valor_unitario || 0);
                        let valorTotal = parseFloat(item.valor_total || item.vProd || 0);
                        
                        // Se valorTotal foi fornecido mas precoUnitario é 0, calcular o preço
                        if (valorTotal > 0 && precoUnitario === 0 && quantidade > 0) {
                            precoUnitario = valorTotal / quantidade;
                        }
                        
                        // Se precoUnitario foi fornecido mas valorTotal é 0, calcular o total
                        if (precoUnitario > 0 && valorTotal === 0) {
                            valorTotal = quantidade * precoUnitario;
                        }
                        
                        // Fallback final: se ainda está 0, usar subtotal da venda dividido por número de itens
                        if (valorTotal === 0 && subtotal > 0) {
                            valorTotal = subtotal / itens.length;
                            // Recalcular preço unitário se necessário
                            if (precoUnitario === 0 && quantidade > 0) {
                                precoUnitario = valorTotal / quantidade;
                            }
                        }
                        
                        // IMPORTANTE: vProd DEVE ser = vUnCom * qCom (com 2 casas decimais)
                        // Arredondar para 2 casas decimais ANTES de fazer a multiplicação
                        precoUnitario = parseFloat(precoUnitario.toFixed(2));
                        quantidade = parseFloat(quantidade.toFixed(4)); // quantidade pode ter mais casas
                        valorTotal = parseFloat((precoUnitario * quantidade).toFixed(2));
                        
                        console.log(`📦 [NuvemFiscal] Item ${index + 1}:`, { 
                            descricao: item.descricao,
                            quantidade, 
                            precoUnitario, 
                            valorTotal,
                            calculo: `${precoUnitario} × ${quantidade} = ${valorTotal}`
                        });
                        
                        return {
                            nItem: index + 1,
                            prod: {
                                cProd: String(item.codigo_produto || item.cProd || '000'),
                                cEAN: item.codigo_barras || 'SEM GTIN',
                                xProd: String(item.descricao || item.xProd || 'PRODUTO'),
                                NCM: item.ncm || '00000000',
                                CFOP: item.cfop || '5102',
                                uCom: item.unidade || 'UN',
                                qCom: quantidade,
                                vUnCom: precoUnitario,
                                vProd: valorTotal,
                                cEANTrib: item.codigo_barras || 'SEM GTIN',
                                uTrib: item.unidade || 'UN',
                                qTrib: quantidade,
                                vUnTrib: precoUnitario,
                                indTot: 1
                            },
                            imposto: {
                                ICMS: {
                                    ICMSSN102: {
                                        orig: 0,
                                        CSOSN: '102'
                                    }
                                }
                            }
                        };
                    }),
                    total: {
                        ICMSTot: {
                            vBC: 0,
                            vICMS: 0,
                            vICMSDeson: 0,
                            vFCP: 0,
                            vBCST: 0,
                            vST: 0,
                            vFCPST: 0,
                            vFCPSTRet: 0,
                            vProd: parseFloat(subtotal.toFixed(2)),
                            vFrete: 0,
                            vSeg: 0,
                            vDesc: parseFloat(desconto.toFixed(2)),
                            vII: 0,
                            vIPI: 0,
                            vIPIDevol: 0,
                            vPIS: 0,
                            vCOFINS: 0,
                            vOutro: 0,
                            vNF: parseFloat(valorTotal.toFixed(2)),
                            vTotTrib: 0
                        }
                    },
                    transp: {
                        modFrete: 9 // 9=Sem frete
                    },
                    pag: {
                        detPag: [{
                            tPag: this.mapearFormaPagamento(venda.forma_pagamento),
                            xPag: venda.forma_pagamento_descricao || this.obterDescricaoPagamento(venda.forma_pagamento),
                            vPag: parseFloat(valorTotal.toFixed(2))
                        }],
                        vTroco: parseFloat(troco.toFixed(2))
                    }
                }
            };

            // Adicionar destinatário se houver
            if (destinatario && destinatario.cpf_cnpj) {
                payload.infNFe.dest = {
                    [destinatario.cpf_cnpj.length === 11 ? 'CPF' : 'CNPJ']: destinatario.cpf_cnpj,
                    xNome: destinatario.nome_completo
                };
            }

            // Adicionar informações adicionais se houver
            if (venda.observacoes) {
                payload.infNFe.infAdic = {
                    infCpl: venda.observacoes
                };
            }

            console.log('🏙️ [NuvemFiscal] Verificação final - cMunFG:', payload.infNFe.ide.cMunFG, 'cMun:', payload.infNFe.emit.enderEmit.cMun);
            console.log('📦 [NuvemFiscal] Payload completo:', JSON.stringify(payload, null, 2));

            return payload;
        } catch (erro) {
            console.error('Erro ao montar payload NFC-e:', erro);
            throw erro;
        }
    }

    /**
     * Mapear forma de pagamento do sistema para código da NFC-e
     */
    mapearFormaPagamento(formaPagamento) {
        const mapa = {
            'dinheiro': '01',
            'cartao_credito': '03',
            'cartao_debito': '04',
            'pix': '17',
            'transferencia': '18',
            'boleto': '15',
            'outros': '99'
        };

        return mapa[formaPagamento] || '99';
    }

    /**
     * Obter descrição legível da forma de pagamento
     */
    obterDescricaoPagamento(formaPagamento) {
        const descricoes = {
            'dinheiro': 'Dinheiro',
            'cartao_credito': 'Cartão de Crédito',
            'cartao_debito': 'Cartão de Débito',
            'pix': 'PIX',
            'transferencia': 'Transferência Bancária',
            'boleto': 'Boleto Bancário',
            'outros': 'Outros'
        };

        return descricoes[formaPagamento] || 'Outros';
    }

    /**
     * Validar resposta da API
     */
    validarResposta(resposta) {
        if (!resposta) {
            throw new Error('Resposta vazia da API');
        }

        if (resposta.status === 'rejeitado' || resposta.status === 'erro') {
            console.error('❌ [NuvemFiscal] Rejeição completa:', resposta);
            console.error('❌ [NuvemFiscal] Autorização:', resposta.autorizacao);
            
            // Buscar mensagens de erro em diferentes lugares
            let mensagens = '';
            
            if (resposta.autorizacao?.mensagens) {
                mensagens = resposta.autorizacao.mensagens.map(m => 
                    `[${m.codigo}] ${m.mensagem}`
                ).join('; ');
            } else if (resposta.autorizacao?.motivo_status) {
                mensagens = `[${resposta.autorizacao.codigo_status}] ${resposta.autorizacao.motivo_status}`;
            } else if (resposta.autorizacao?.motivo) {
                mensagens = `[${resposta.autorizacao.codigo_status}] ${resposta.autorizacao.motivo}`;
            } else if (resposta.mensagens) {
                mensagens = resposta.mensagens.map(m => m.mensagem).join('; ');
            } else if (resposta.motivo_status) {
                mensagens = `[${resposta.codigo_status}] ${resposta.motivo_status}`;
            } else {
                mensagens = 'Erro desconhecido';
            }
            
            throw new Error(`NFC-e rejeitada: ${mensagens}`);
        }

        return resposta;
    }
}

// Exportar instância única
const NuvemFiscal = new NuvemFiscalService();
