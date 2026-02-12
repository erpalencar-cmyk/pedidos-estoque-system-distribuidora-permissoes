// =====================================================
// SISTEMA DE CONTROLE DE ACESSO (RBAC)
// Arquivo: js/auth-rbac.js
// Propósito: Verificar permissões e proteger páginas
// =====================================================

/**
 * Mapeamento de páginas para slugs de módulos (para verificação de permissões granulares)
 */
const PAGE_TO_MODULE_SLUG = {
    'pdv.html': 'pdv',
    'produtos.html': 'produtos',
    'categorias.html': 'categorias',
    'marcas.html': 'marcas',
    'estoque.html': 'estoque',
    'vendas.html': 'vendas',
    'pedidos.html': 'pedidos-compra',
    'clientes.html': 'clientes',
    'fornecedores.html': 'fornecedores',
    'contas-receber.html': 'contas-receber',
    'contas-pagar.html': 'contas-pagar',
    'caixas.html': 'caixas',
    'usuarios.html': 'usuarios',
    'configuracoes-empresa.html': 'configuracoes',
    'gerenciar-permissoes.html': 'gerenciar-permissoes'
};

/**
 * Normalizar role para aceitar múltiplas variações de admin
 * @param {string} role - Role original
 * @returns {string} Role normalizado
 */
function normalizeRole(role) {
    if (!role) return null;
    const normalized = role.toUpperCase();
    if (normalized === 'ADMIN' || normalized === 'ADMINISTRADOR') {
        return 'ADMIN';
    }
    return role;
}

/**
 * Definição de roles e permissões
 * Estrutura: página -> roles permitidas
 */
const RBAC_PERMISSIONS = {
    // Dashboard - Todos podem ver
    'dashboard.html': ['ADMIN', 'GERENTE', 'VENDEDOR', 'OPERADOR_CAIXA', 'ESTOQUISTA', 'COMPRADOR', 'APROVADOR'],
    
    // PDV - Apenas Vendedor/Operador de Caixa
    'pdv.html': ['ADMIN', 'OPERADOR_CAIXA', 'VENDEDOR'],
    
    // Gerenciamento de Estoque - Admin, Gerente, Estoquista
    'estoque.html': ['ADMIN', 'GERENTE', 'ESTOQUISTA'],
    'estoque-novo.html': ['ADMIN', 'GERENTE', 'ESTOQUISTA'],
    'reprocessar-estoque.html': ['ADMIN'],
    
    // Produtos - Admin, Gerente, Comprador
    'produtos.html': ['ADMIN', 'GERENTE', 'COMPRADOR', 'ESTOQUISTA'],
    'categorias.html': ['ADMIN', 'GERENTE'],
    'marcas.html': ['ADMIN', 'GERENTE'],
    
    // Pedidos e Vendas - Múltiplos roles
    'pedidos.html': ['ADMIN', 'GERENTE', 'COMPRADOR', 'APROVADOR'],
    'pedido-detalhe.html': ['ADMIN', 'GERENTE', 'COMPRADOR', 'APROVADOR'],
    'vendas.html': ['ADMIN', 'GERENTE', 'VENDEDOR', 'OPERADOR_CAIXA'],
    'vendas-pendentes.html': ['ADMIN', 'GERENTE', 'VENDEDOR', 'OPERADOR_CAIXA'],
    'venda-detalhe.html': ['ADMIN', 'GERENTE', 'VENDEDOR', 'OPERADOR_CAIXA'],
    'pre-pedidos.html': ['ADMIN', 'GERENTE', 'COMPRADOR', 'APROVADOR'],
    
    // Conferência e Separação
    'conferencia-vendas.html': ['ADMIN', 'GERENTE', 'ESTOQUISTA'],
    
    // Financeiro
    'contas-receber.html': ['ADMIN', 'GERENTE', 'OPERADOR_CAIXA'],
    'contas-pagar.html': ['ADMIN', 'GERENTE', 'COMPRADOR'],
    'caixas.html': ['ADMIN', 'OPERADOR_CAIXA'],
    'analise-financeira.html': ['ADMIN', 'GERENTE'],
    'analise-lucros.html': ['ADMIN', 'GERENTE'],
    
    // CRM
    'clientes.html': ['ADMIN', 'GERENTE', 'VENDEDOR', 'COMPRADOR'],
    'fornecedores.html': ['ADMIN', 'GERENTE', 'COMPRADOR'],
    
    // Admin - Apenas ADMIN
    'usuarios.html': ['ADMIN'],
    'aprovacao-usuarios.html': ['ADMIN'],
    'configuracoes-empresa.html': ['ADMIN'],
    'analise.html': ['ADMIN', 'GERENTE']
};

/**
 * Verificar se o usuário tem permissão para acessar a página atual
 * @param {Object} user - Objeto do usuário autenticado
 * @param {string} pageName - Nome do arquivo HTML (ex: 'usuarios.html')
 * @returns {boolean} true se tem permissão, false caso contrário
 */
function hasPageAccess(user, pageName) {
    if (!user) return false;
    if (!pageName) return false;
    
    // ADMIN tem acesso a tudo
    const normalizedRole = normalizeRole(user.role);
    if (normalizedRole === 'ADMIN') return true;
    
    // Verificar se página restringe acesso
    const allowedRoles = RBAC_PERMISSIONS[pageName];
    if (!allowedRoles) {
        // Se página não está mapeada, permitir (modo falha aberto)
        console.warn(`⚠️ Página não mapeada em RBAC: ${pageName}`);
        return true;
    }
    
    return allowedRoles.includes(normalizeRole(user.role));
}

/**
 * Verificar se página é acessível e redirecionar se não
 * DEVE SER CHAMADA NO INÍCIO DE CADA PÁGINA
 */
async function protectPageAccess() {
    try {
        // Obter usuário atual
        const user = await getCurrentUser();
        
        if (!user) {
            console.warn('🔒 Usuário não autenticado, redirecionando para login');
            window.location.href = '/index.html';
            return false;
        }
        
        // Obter nome da página atual
        const currentPage = window.location.pathname.split('/').pop();
        
        // Verificar permissão por ROLE (verificação básica)
        if (!hasPageAccess(user, currentPage)) {
            console.error(`🔒 Acesso negado por ROLE para ${currentPage} com role ${user.role}`);
            
            // Mostrar alerta
            showToast(
                `❌ Você não tem permissão para acessar esta página. Seu perfil é: ${user.role}`,
                'error',
                5000
            );
            
            // Redirecionar para dashboard
            setTimeout(() => {
                window.location.href = '/pages/dashboard.html';
            }, 2000);
            
            return false;
        }

        // Se existe sistema de permissões granulares e arquivo permissoes.js foi carregado
        if (typeof permissaoManager !== 'undefined' && permissaoManager) {
            const moduleSlug = PAGE_TO_MODULE_SLUG[currentPage];
            
            if (moduleSlug) {
                // Inicializar permissao manager se ainda não foi
                if (!permissaoManager.usuarioId) {
                    await permissaoManager.inicializar();
                }
                
                // Verificar permissão granular
                const temPermissaoModulo = await permissaoManager.podeAcessarModulo(moduleSlug);
                
                if (!temPermissaoModulo) {
                    console.error(`🔒 Acesso negado por MÓDULO para ${currentPage} (módulo: ${moduleSlug})`);
                    
                    showToast(
                        `❌ Seu administrador não liberou acesso a este módulo.`,
                        'error',
                        5000
                    );
                    
                    setTimeout(() => {
                        window.location.href = '/pages/dashboard.html';
                    }, 2000);
                    
                    return false;
                }
            }
        }
        
        console.log(`✅ Acesso permitido: ${currentPage} para ${user.role}`);
        return true;
        
    } catch (error) {
        console.error('Erro ao verificar acesso à página:', error);
        window.location.href = '/index.html';
        return false;
    }
}

/**
 * Verificar se usuário tem permissão para ação específica
 * @param {string} action - Ação (ex: 'delete', 'edit', 'approve')
 * @param {string} resource - Recurso (ex: 'user', 'pedido')
 * @returns {boolean}
 */
function canPerformAction(user, action, resource) {
    if (!user) return false;
    
    // ADMIN pode fazer tudo
    const normalizedRole = normalizeRole(user.role);
    if (normalizedRole === 'ADMIN') return true;
    
    // Definir permissões por ação e recurso
    const permissions = {
        'delete': {
            'user': ['ADMIN'],
            'pedido': ['ADMIN'],
            'cliente': ['ADMIN', 'GERENTE'],
            'produto': ['ADMIN', 'GERENTE']
        },
        'approve': {
            'pedido': ['ADMIN', 'APROVADOR', 'GERENTE'],
            'venda': ['ADMIN', 'GERENTE']
        },
        'finalize': {
            'venda': ['ADMIN', 'OPERADOR_CAIXA', 'VENDEDOR'],
            'pedido': ['ADMIN', 'GERENTE']
        },
        'export': {
            'relatorio': ['ADMIN', 'GERENTE']
        }
    };
    
    const resourcePermissions = permissions[action];
    if (!resourcePermissions) {
        console.warn(`⚠️ Ação não mapeada em RBAC: ${action}`);
        return false;
    }
    
    const allowedRoles = resourcePermissions[resource];
    if (!allowedRoles) {
        console.warn(`⚠️ Recurso não mapeado para ação ${action}: ${resource}`);
        return false;
    }
    
    return allowedRoles.includes(normalizeRole(user.role));
}

/**
 * Verificar se usuário é de um papel específico
 * @param {string} role - Papel a verificar
 * @returns {boolean}
 */
    async function isRole(role) {
    try {
        const user = await getCurrentUser();
        if (!user) return false;
        const normalizedUserRole = normalizeRole(user.role);
        const normalizedCheckRole = normalizeRole(role);
        return normalizedUserRole === normalizedCheckRole || normalizedUserRole === 'ADMIN';
    } catch (error) {
        console.error('Erro ao verificar role:', error);
        return false;
    }
}

/**
 * Esconder elemento se usuário não tiver permissão
 * Uso: hideIfNoAccess('elemento-id', 'usuarios.html')
 */
function hideIfNoAccess(elementId, requiredRole = null) {
    const element = document.getElementById(elementId);
    if (!element) return;
    
    (async () => {
        try {
            const user = await getCurrentUser();
            
            let hasAccess = false;
            if (requiredRole) {
                const normalizedUserRole = normalizeRole(user.role);
                const normalizedRequiredRole = normalizeRole(requiredRole);
                hasAccess = user && (normalizedUserRole === normalizedRequiredRole || normalizedUserRole === 'ADMIN');
            } else {
                hasAccess = user ? true : false;
            }
            
            if (!hasAccess) {
                element.style.display = 'none';
            }
        } catch (error) {
            console.error('Erro ao verificar acesso:', error);
            element.style.display = 'none';
        }
    })();
}

/**
 * Desabilitar botão se usuário não tiver permissão
 * Uso: disableIfNoAccess('btn-delete', 'delete', 'pedido')
 */
function disableIfNoAccess(buttonId, action, resource) {
    const button = document.getElementById(buttonId);
    if (!button) return;
    
    (async () => {
        try {
            const user = await getCurrentUser();
            
            if (!canPerformAction(user, action, resource)) {
                button.disabled = true;
                button.title = `Você não tem permissão para ${action}`;
                button.style.opacity = '0.5';
                button.style.cursor = 'not-allowed';
            }
        } catch (error) {
            console.error('Erro ao verificar acesso:', error);
            button.disabled = true;
        }
    })();
}

/**
 * Log de auditoria - registrar ações do usuário
 */
async function auditLog(acao, recurso, detalhes = {}) {
    try {
        const user = await getCurrentUser();
        if (!user) return;
        
        const log = {
            usuario_id: user.id,
            acao,
            recurso,
            detalhes: JSON.stringify(detalhes),
            ip_address: '', // Será preenchido pelo servidor
            user_agent: navigator.userAgent,
            created_at: new Date().toISOString()
        };
        
        console.log('📝 Auditoria:', log);
        
        // Enviar para banco (implementar depois)
        // await supabase.from('auditoria_log').insert([log]);
        
    } catch (error) {
        console.error('Erro ao registrar log de auditoria:', error);
    }
}

// =====================================================
// EXPORTAR FUNÇÕES
// =====================================================
// Usar em cada página:
// 
// <script src="../js/auth-rbac.js"></script>
// <script>
//     (async () => {
//         await checkAuth();
//         await protectPageAccess();
//         // ... resto do código
//     })();
// </script>
