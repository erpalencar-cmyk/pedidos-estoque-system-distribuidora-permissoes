// =====================================================
// SISTEMA DE CONTROLE DE ACESSO (RBAC)
// Arquivo: js/auth-rbac.js
// Propósito: Verificar permissões e proteger páginas
// Agora integrado com permissões dinâmicas (tabela usuarios_modulos)
// =====================================================

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
 * Mapeamento de página HTML → slug de módulo
 * Usado para proteger o acesso direto via URL
 */
const PAGE_MODULE_MAP = {
    'dashboard.html': 'dashboard',
    'produtos.html': 'produtos',
    'categorias.html': 'produtos',
    'marcas.html': 'produtos',
    'fornecedores.html': 'fornecedores',
    'clientes.html': 'clientes',
    'clientes-template.html': 'clientes',
    'usuarios.html': 'usuarios',
    'gerenciar-permissoes.html': 'gerenciar-permissoes',
    'aprovacao-usuarios.html': 'aprovacao-usuarios',
    'configuracoes-empresa.html': 'configuracoes-empresa',
    'pdv.html': 'pdv',
    'comandas.html': 'comandas',
    'caixas.html': 'caixas',
    'estoque.html': 'estoque',
    'controle-validade.html': 'controle-validade',
    'pedidos.html': 'pedidos',
    'pedido-detalhe.html': 'pedidos',
    'vendas.html': 'vendas',
    'vendas-pendentes.html': 'vendas-pendentes',
    'venda-detalhe.html': 'vendas',
    'conferencia-vendas.html': 'conferencia-vendas',
    'aprovacao.html': 'aprovacao',
    'pre-pedidos.html': 'pre-pedidos',
    'contas-pagar.html': 'contas-pagar',
    'contas-receber.html': 'contas-receber',
    'analise-financeira.html': 'analise-financeira',
    'analise-lucros.html': 'analise-financeira',
    'analise.html': 'analise-financeira',
    'documentos-fiscais.html': 'documentos-fiscais',
    'distribuicao-nfce.html': 'distribuicao-nfce',
    'teste-focus-nfe.html': 'teste-focus-nfe',
    'teste-nuvem-fiscal.html': 'teste-nuvem-fiscal',
    'reprocessar-estoque.html': 'reprocessar-estoque'
};

/**
 * Módulos exclusivos de ADMIN
 */
const ADMIN_ONLY_PAGES = [
    'usuarios', 'gerenciar-permissoes', 'aprovacao-usuarios',
    'teste-focus-nfe', 'teste-nuvem-fiscal',
    'reprocessar-estoque'
];

/**
 * Verificar se o usuário tem permissão para acessar a página atual
 * Usa permissões dinâmicas da tabela usuarios_modulos
 * @param {Object} user - Objeto do usuário autenticado
 * @param {string} pageName - Nome do arquivo HTML (ex: 'usuarios.html')
 * @param {string[]} permittedSlugs - Lista de slugs permitidos (opcional, para evitar re-query)
 * @returns {boolean}
 */
function hasPageAccess(user, pageName, permittedSlugs = null) {
    if (!user) return false;
    if (!pageName) return false;
    
    // ADMIN tem acesso a tudo
    const normalizedRole = normalizeRole(user.role);
    if (normalizedRole === 'ADMIN') return true;
    
    // Obter o slug do módulo da página
    const moduleSlug = PAGE_MODULE_MAP[pageName];
    if (!moduleSlug) {
        // Página não mapeada — permitir (modo falha aberto)
        console.warn(`⚠️ Página não mapeada em PAGE_MODULE_MAP: ${pageName}`);
        return true;
    }

    // Dashboard sempre acessível
    if (moduleSlug === 'dashboard') return true;

    // Módulos exclusivos de admin
    if (ADMIN_ONLY_PAGES.includes(moduleSlug)) {
        return false;
    }

    // Se temos lista de slugs permitidos, verificar
    if (permittedSlugs) {
        return permittedSlugs.includes('*') || permittedSlugs.includes(moduleSlug);
    }

    // Sem lista de slugs — não temos como verificar sincronamente
    // Usar protectPageAccess() (async) é o recomendado
    console.warn(`⚠️ hasPageAccess sem permittedSlugs para ${pageName} — use protectPageAccess() (async)`);
    return true;
}

/**
 * Verificar se página é acessível e redirecionar se não
 * Usa permissões dinâmicas do banco de dados
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
        
        // ADMIN tem acesso a tudo
        const normalizedRole = normalizeRole(user.role);
        if (normalizedRole === 'ADMIN') {
            console.log('✅ Acesso liberado: ADMIN');
            return true;
        }

        // Obter nome da página atual
        const currentPage = window.location.pathname.split('/').pop();

        // Obter slug do módulo
        const moduleSlug = PAGE_MODULE_MAP[currentPage];
        if (!moduleSlug) {
            console.warn(`⚠️ Página não mapeada: ${currentPage} — acesso permitido`);
            return true;
        }

        // Dashboard sempre acessível
        if (moduleSlug === 'dashboard') {
            return true;
        }

        // Módulos exclusivos de admin — negar para não-admin
        if (ADMIN_ONLY_PAGES.includes(moduleSlug)) {
            console.error(`🔒 Acesso negado: ${currentPage} é exclusivo de ADMIN`);
            showToast('❌ Acesso exclusivo para administradores.', 'error', 5000);
            setTimeout(() => { window.location.href = '/pages/dashboard.html'; }, 2000);
            return false;
        }

        // Verificar permissão na tabela usuarios_modulos
        let temAcesso = false;
        try {
            const { data, error } = await window.supabase
                .from('usuarios_modulos')
                .select('pode_acessar, modulos!inner(slug)')
                .eq('usuario_id', user.id)
                .eq('modulos.slug', moduleSlug)
                .eq('pode_acessar', true)
                .maybeSingle();

            if (!error && data) {
                temAcesso = true;
            }
        } catch (err) {
            console.warn('⚠️ Erro ao consultar permissões:', err);
            // Em caso de erro, usar fallback permissivo para não bloquear
            temAcesso = true;
        }

        if (!temAcesso) {
            console.error(`🔒 Acesso negado para ${currentPage} (módulo: ${moduleSlug}) — role: ${user.role}`);
            showToast(
                `❌ Você não tem permissão para acessar esta página. Peça ao administrador para liberar o acesso.`,
                'error',
                5000
            );
            setTimeout(() => { window.location.href = '/pages/dashboard.html'; }, 2000);
            return false;
        }
        
        console.log(`✅ Acesso permitido: ${currentPage} (módulo: ${moduleSlug})`);
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
