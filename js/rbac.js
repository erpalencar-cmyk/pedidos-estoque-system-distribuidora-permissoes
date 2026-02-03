/**
 * RBAC - Sistema de Controle de Acesso Baseado em Funções
 * Integrado com Supabase Auth
 */

class RBACSystem {
    static PERMISSIONS = {
        'ADMIN': {
            usuarios: ['create', 'read', 'update', 'delete', 'approve'],
            configuracoes: ['read', 'update'],
            relatorios: ['read', 'create'],
            estoque: ['read', 'update', 'reprocessar'],
            caixa: ['abrir', 'fechar', 'consultar'],
            vendas: ['criar', 'consultar', 'cancelar']
        },
        'GERENTE': {
            usuarios: ['read'],
            configuracoes: ['read'],
            relatorios: ['read'],
            estoque: ['read', 'update'],
            caixa: ['consultar'],
            vendas: ['consultar'],
            aprovacoes: ['ler', 'aprovar']
        },
        'OPERADOR_CAIXA': {
            caixa: ['abrir', 'fechar', 'consultar'],
            vendas: ['criar', 'consultar'],
            estoque: ['read']
        },
        'ESTOQUISTA': {
            estoque: ['read', 'update'],
            vendas: ['consultar'],
            estoque_movimentacoes: ['read', 'create']
        },
        'VENDEDOR': {
            vendas: ['consultar'],
            clientes: ['read', 'update'],
            pedidos: ['create', 'read']
        },
        'COMPRADOR': {
            fornecedores: ['read'],
            compras: ['create', 'read'],
            estoque: ['read']
        },
        'APROVADOR': {
            aprovacoes: ['ler', 'aprovar', 'rejeitar'],
            relatorios: ['read']
        }
    };

    /**
     * Verificar se usuário tem permissão
     */
    static async verificarPermissao(modulo, acao) {
        try {
            const usuario = await getCurrentUser();
            const perms = this.PERMISSIONS[usuario.role] || {};
            const moduloPerms = perms[modulo] || [];
            return moduloPerms.includes(acao);
        } catch (error) {
            return false;
        }
    }

    /**
     * Proteger página - redirecionar se sem acesso
     */
    static async protegerPagina(rolesPermitidos = ['ADMIN']) {
        try {
            const usuario = await getCurrentUser();
            
            if (!rolesPermitidos.includes(usuario.role)) {
                showToast('Acesso negado. Você não tem permissão para acessar esta página.', 'error');
                setTimeout(() => window.location.href = '/pages/dashboard.html', 2000);
                return false;
            }
            return true;
        } catch (error) {
            window.location.href = '/pages/auth-callback.html';
            return false;
        }
    }

    /**
     * Ocultar elemento se sem acesso
     */
    static async ocultarSemAcesso(seletor, modulo, acao) {
        if (!(await this.verificarPermissao(modulo, acao))) {
            document.querySelectorAll(seletor).forEach(el => {
                el.style.display = 'none';
            });
        }
    }

    /**
     * Desabilitar elemento se sem acesso
     */
    static async desabilitarSemAcesso(seletor, modulo, acao) {
        if (!(await this.verificarPermissao(modulo, acao))) {
            document.querySelectorAll(seletor).forEach(el => {
                el.disabled = true;
                el.style.opacity = '0.5';
            });
        }
    }

    /**
     * Registrar ação auditada
     */
    static async registrarAuditoria(tabelaNome, operacao, registroId, dadosNovos) {
        try {
            const usuario = await getCurrentUser();
            await supabase
                .from('auditoria_log')
                .insert({
                    tabela_nome: tabelaNome,
                    operacao: operacao,
                    registro_id: registroId,
                    dados_novos: dadosNovos,
                    usuario_id: usuario.id,
                    ip_address: await this.obterIP()
                });
        } catch (error) {
            console.error('Erro ao registrar auditoria:', error);
        }
    }

    /**
     * Obter IP (aproximação via fetch)
     */
    static async obterIP() {
        try {
            const response = await fetch('https://api.ipify.org?format=json');
            const data = await response.json();
            return data.ip;
        } catch (error) {
            return 'desconhecido';
        }
    }
}

// Exportar para uso global
window.RBACSystem = RBACSystem;
