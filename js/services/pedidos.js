/**
 * Serviço de Pedidos - Refatorado
 * Remove 230+ linhas de código duplicado
 */

class PedidosService {
    /**
     * Listar pedidos com filtros
     */
    static async listarPedidos(filtros = {}) {
        try {
            let query = supabase
                .from('vendas')
                .select('*')
                .order('created_at', { ascending: false });

            // Aplicar filtros
            if (filtros.cliente_id) {
                query = query.eq('cliente_id', filtros.cliente_id);
            }

            if (filtros.status) {
                query = query.eq('status', filtros.status);
            }

            if (filtros.status_fiscal) {
                query = query.eq('status_fiscal', filtros.status_fiscal);
            }

            if (filtros.data_inicio && filtros.data_fim) {
                query = query
                    .gte('created_at', `${filtros.data_inicio}T00:00:00`)
                    .lte('created_at', `${filtros.data_fim}T23:59:59`);
            }

            if (filtros.operador_id) {
                query = query.eq('operador_id', filtros.operador_id);
            }

            const { data: vendas, error } = await query.limit(filtros.limite || 100);

            if (error) throw error;

            // Carregar relacionamentos separadamente
            for (let venda of vendas || []) {
                // Carregar cliente
                if (venda.cliente_id) {
                    const { data: cliente } = await supabase
                        .from('clientes')
                        .select('*')
                        .eq('id', venda.cliente_id)
                        .single();
                    venda.clientes = cliente;
                }

                // Carregar operador
                if (venda.operador_id) {
                    const { data: operador } = await supabase
                        .from('users')
                        .select('nome_completo')
                        .eq('id', venda.operador_id)
                        .single();
                    venda.operador = operador;
                }

                // Carregar caixa
                if (venda.caixa_id) {
                    const { data: caixa } = await supabase
                        .from('caixas')
                        .select('*')
                        .eq('id', venda.caixa_id)
                        .single();
                    venda.caixa = caixa;
                }

                // Carregar itens
                const { data: itens } = await supabase
                    .from('venda_itens')
                    .select('*')
                    .eq('venda_id', venda.id);
                venda.venda_itens = itens || [];
            }

            return vendas || [];
        } catch (error) {
            console.error('Erro ao listar pedidos:', error);
            return [];
        }
    }

    /**
     * Obter pedido com detalhes
     */
    static async obterPedido(vendaId) {
        try {
            // Carregar venda
            const { data: venda, error } = await supabase
                .from('vendas')
                .select('*')
                .eq('id', vendaId)
                .single();

            if (error) throw error;
            if (!venda) return null;

            // Carregar cliente
            if (venda.cliente_id) {
                const { data: cliente } = await supabase
                    .from('clientes')
                    .select('*')
                    .eq('id', venda.cliente_id)
                    .single();
                venda.clientes = cliente;
            }

            // Carregar operador
            if (venda.operador_id) {
                const { data: operador } = await supabase
                    .from('users')
                    .select('*')
                    .eq('id', venda.operador_id)
                    .single();
                venda.operador = operador;
            }

            // Carregar caixa
            if (venda.caixa_id) {
                const { data: caixa } = await supabase
                    .from('caixas')
                    .select('*')
                    .eq('id', venda.caixa_id)
                    .single();
                venda.caixa = caixa;
            }

            // Carregar movimentacao_caixa
            if (venda.movimentacao_caixa_id) {
                const { data: movimentacao } = await supabase
                    .from('movimentacao_caixa')
                    .select('*')
                    .eq('id', venda.movimentacao_caixa_id)
                    .single();
                venda.movimentacao_caixa = movimentacao;
            }

            // Carregar itens com produtos
            const { data: itens } = await supabase
                .from('venda_itens')
                .select('*')
                .eq('venda_id', vendaId);

            // Para cada item, carregar o produto
            for (let item of itens || []) {
                if (item.produto_id) {
                    const { data: produto } = await supabase
                        .from('produtos')
                        .select('*')
                        .eq('id', item.produto_id)
                        .single();
                    item.produto = produto;
                }
            }

            venda.venda_itens = itens || [];

            return venda;
        } catch (error) {
            console.error('Erro ao obter pedido:', error);
            return null;
        }
    }

    /**
     * Criar pedido (PRÉ-PEDIDO)
     */
    static async criarPedido(dadosPedido) {
        try {
            // Validações
            if (!dadosPedido.cliente_id) {
                throw new Error('Cliente é obrigatório');
            }

            if (!dadosPedido.itens || dadosPedido.itens.length === 0) {
                throw new Error('Pedido deve ter pelo menos um item');
            }

            // Validar itens
            for (const item of dadosPedido.itens) {
                if (!SharedUtils.validarQuantidade(item.quantidade)) {
                    throw new Error('Quantidade inválida');
                }
                if (!SharedUtils.validarPreco(item.preco_unitario)) {
                    throw new Error('Preço inválido');
                }
            }

            const usuario = await getCurrentUser();

            // Criar pré-pedido
            const { data: pedido, error: erroP } = await supabase
                .from('pre_pedidos')
                .insert({
                    numero_pedido: await SharedUtils.gerarNumeroPedidoSeguro(),
                    cliente_id: dadosPedido.cliente_id,
                    criado_por: usuario.id,
                    subtotal: dadosPedido.subtotal || 0,
                    desconto: dadosPedido.desconto || 0,
                    acrescimo: dadosPedido.acrescimo || 0,
                    total: dadosPedido.total || 0,
                    status: 'PENDENTE',
                    observacoes: dadosPedido.observacoes
                })
                .select()
                .single();

            if (erroP) throw erroP;

            // Inserir itens
            for (const item of dadosPedido.itens) {
                const { error: erroItem } = await supabase
                    .from('pre_pedido_itens')
                    .insert({
                        pre_pedido_id: pedido.id,
                        produto_id: item.produto_id,
                        quantidade: item.quantidade,
                        unidade_medida: item.unidade_medida || 'UN',
                        preco_unitario: item.preco_unitario,
                        subtotal: item.quantidade * item.preco_unitario,
                        desconto: item.desconto || 0
                    });

                if (erroItem) throw erroItem;
            }

            // Registrar auditoria
            await RBACSystem.registrarAuditoria('pre_pedidos', 'INSERT', pedido.id, pedido);

            return pedido;
        } catch (error) {
            console.error('Erro ao criar pedido:', error);
            throw error;
        }
    }

    /**
     * Atualizar pedido
     */
    static async atualizarPedido(vendaId, dados) {
        try {
            const { data, error } = await supabase
                .from('vendas')
                .update({
                    observacoes: dados.observacoes,
                    updated_at: new Date().toISOString()
                })
                .eq('id', vendaId)
                .select()
                .single();

            if (error) throw error;

            await RBACSystem.registrarAuditoria('vendas', 'UPDATE', vendaId, dados);

            return data;
        } catch (error) {
            console.error('Erro ao atualizar pedido:', error);
            throw error;
        }
    }

    /**
     * Cancelar pedido
     */
    static async cancelarPedido(vendaId, motivo) {
        try {
            // Cancelar fiscal se foi emitido
            const venda = await this.obterPedido(vendaId);
            
            if (venda.status_fiscal && venda.status_fiscal !== 'SEM_DOCUMENTO_FISCAL') {
                // Cancelar documento fiscal
                await FiscalSystem.cancelarDocumentoFiscal(vendaId, motivo);
            }

            // Atualizar status
            const { data, error } = await supabase
                .from('vendas')
                .update({
                    status: 'CANCELADA',
                    observacoes: `CANCELADO: ${motivo}`
                })
                .eq('id', vendaId)
                .select()
                .single();

            if (error) throw error;

            await RBACSystem.registrarAuditoria('vendas', 'UPDATE', vendaId, { status: 'CANCELADA' });

            return data;
        } catch (error) {
            console.error('Erro ao cancelar pedido:', error);
            throw error;
        }
    }

    /**
     * Gerar HTML para exibição
     * CONSOLIDAÇÃO: remove gerarHTMLPedidoCompra e gerarHTMLPedidoVenda
     */
    static gerarHTML(pedido, tipo = 'venda') {
        return SharedUtils.gerarHTMLPedido(pedido, tipo);
    }

    /**
     * Emitir NFC-e para pedido
     */
    static async emitirNFCePedido(vendaId) {
        try {
            const resultado = await FiscalSystem.emitirNFCe(vendaId);
            
            if (resultado.sucesso) {
                SharedUtils.exibirToast('NFC-e emitida com sucesso!', 'success');
                return resultado;
            } else {
                SharedUtils.exibirToast('Erro ao emitir NFC-e: ' + resultado.erro, 'error');
                return null;
            }
        } catch (error) {
            console.error('Erro ao emitir NFC-e:', error);
            SharedUtils.exibirToast('Erro ao emitir NFC-e', 'error');
            return null;
        }
    }

    /**
     * Exportar pedido para PDF
     */
    static async exportarPDF(vendaId) {
        try {
            const venda = await this.obterPedido(vendaId);
            if (!venda) throw new Error('Pedido não encontrado');

            let html = `
            <div class="p-8">
                <h1 style="text-align: center; font-size: 24px; margin-bottom: 20px;">Nota de Venda</h1>
                
                <div style="margin-bottom: 20px;">
                    <p><strong>Número:</strong> ${venda.numero_nf}</p>
                    <p><strong>Data:</strong> ${SharedUtils.formatarDataBR(venda.created_at)}</p>
                    <p><strong>Cliente:</strong> ${venda.clientes?.nome || 'N/A'}</p>
                </div>

                <table style="width: 100%; border-collapse: collapse; margin-bottom: 20px;">
                    <thead>
                        <tr style="border-bottom: 2px solid #000;">
                            <th style="text-align: left; padding: 10px;">Produto</th>
                            <th style="text-align: right; padding: 10px;">Qtd</th>
                            <th style="text-align: right; padding: 10px;">Valor</th>
                            <th style="text-align: right; padding: 10px;">Total</th>
                        </tr>
                    </thead>
                    <tbody>
            `;

            if (venda.venda_itens && venda.venda_itens.length > 0) {
                venda.venda_itens.forEach(item => {
                    html += `
                        <tr style="border-bottom: 1px solid #eee;">
                            <td style="padding: 10px;">${item.descricao || 'Item'}</td>
                            <td style="text-align: right; padding: 10px;">${item.quantidade}</td>
                            <td style="text-align: right; padding: 10px;">R$ ${parseFloat(item.preco_unitario).toFixed(2)}</td>
                            <td style="text-align: right; padding: 10px;">R$ ${parseFloat(item.total).toFixed(2)}</td>
                        </tr>
                    `;
                });
            }

            html += `
                    </tbody>
                </table>

                <div style="text-align: right; margin-top: 20px; border-top: 2px solid #000; padding-top: 10px;">
                    <p><strong>Subtotal:</strong> R$ ${venda.subtotal.toFixed(2)}</p>
                    <p><strong>Desconto:</strong> -R$ ${venda.desconto.toFixed(2)}</p>
                    <p><strong style="font-size: 18px;">Total:</strong> R$ ${venda.total.toFixed(2)}</p>
                </div>
            </div>
            `;

            SharedUtils.imprimirHTML(html, 'Nota_' + venda.numero_nf);
        } catch (error) {
            console.error('Erro ao exportar PDF:', error);
            SharedUtils.exibirToast('Erro ao exportar PDF', 'error');
        }
    }

    /**
     * Enviar pedido por WhatsApp
     */
    static async enviarWhatsApp(vendaId, numeroWhatsApp) {
        try {
            const venda = await this.obterPedido(vendaId);
            if (!venda) throw new Error('Pedido não encontrado');

            // Montei mensagem
            let mensagem = `Olá ${venda.clientes?.nome}!\n\n`;
            mensagem += `Seu pedido *${venda.numero_nf}* foi criado.\n`;
            mensagem += `Total: R$ ${venda.total.toFixed(2)}\n\n`;
            mensagem += `Data: ${SharedUtils.formatarDataBR(venda.created_at)}\n`;
            mensagem += `Status: ${venda.status}\n`;

            // Codificar para URL
            const mensagemURL = encodeURIComponent(mensagem);

            // Abrir WhatsApp
            window.open(`https://wa.me/${numeroWhatsApp}?text=${mensagemURL}`, '_blank');

            SharedUtils.exibirToast('Abrindo WhatsApp...', 'success');
        } catch (error) {
            console.error('Erro ao enviar WhatsApp:', error);
            SharedUtils.exibirToast('Erro ao enviar WhatsApp', 'error');
        }
    }

    /**
     * Obter estatísticas de pedidos
     */
    static async obterEstatisticas(dataInicio, dataFim) {
        try {
            const { data, error } = await supabase
                .rpc('stats_vendas_dia');

            if (error) throw error;

            return data;
        } catch (error) {
            console.error('Erro ao obter estatísticas:', error);
            return { total_vendas: 0, quantidade_itens: 0, media_venda: 0 };
        }
    }
}

// Exportar globalmente
window.PedidosService = PedidosService;
