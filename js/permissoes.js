/**
 * Sistema de Permissões SIMPLIFICADO - Baseado em ROLE (RBAC)
 * 
 * ⚠️  NOTA: Após testes descobrimos que:
 * - users nem sempre estão propagados em public.users
 * - getCurrentUser() falha frequentemente
 * - Solução: Usar ROLE (ADMIN, VENDEDOR, etc) que é confiável
 * 
 * Quando users forem propagados corretamente, podemos reativar granulares.
 */

class PermissaoManager {
    constructor() {
        this.usuarioId = null;
        this.role = 'VENDEDOR'; // Default role
        this.permissoesCache = {};
    }

    /**
     * Inicializa com role do usuário do Auth
     */
    async inicializar() {
        try {
            // Pega role direto do Supabase Auth (mais confiável)
            const { data: { user: authUser }, error } = await window.supabase.auth.getUser();
            
            if (error || !authUser) {
                console.warn('⚠️ Erro ao pegar auth user:', error?.message);
                this.role = 'VENDEDOR';
                return false;
            }

            this.usuarioId = authUser.id;
            
            // Tenta pegar role de public.users, se falhar usa padrão
            try {
                const { data: userData } = await window.supabase
                    .from('users')
                    .select('role')
                    .eq('id', this.usuarioId)
                    .single();
                
                this.role = userData?.role || 'VENDEDOR';
            } catch (e) {
                // Se falhar, usa o role do metadata do auth ou padrão
                this.role = authUser.user_metadata?.role || 'VENDEDOR';
            }

            console.log(`✅ PermissaoManager: Role = ${this.role} (User: ${this.usuarioId})`);
            return true;
        } catch (error) {
            console.error('❌ Erro ao inicializar PermissaoManager:', error);
            this.role = 'VENDEDOR';
            return false;
        }
    }

    /**
     * Verifica permissão pelo ROLE (RBAC - Role Based Access Control)
     * 
     * RBAC:
     * - ADMINtudo
     * - GERENTE: tudo exceto usuários
     * - VENDEDOR: vendas, pdv, produtos, estoque, clientes, caixas, comandas
     * - OPERADOR_CAIXA: pdv, vendas, caixa
     * - ESTOQUISTA: estoque, produtos, controle-validade
     * - COMPRADOR: estoque, produtos, fornecedores, pedidos-compra
     * - APROVADOR: pedidos-compra, contas-pagar, vendas
     */
    async podeAcessarModulo(slugModulo) {
        try {
            // Inicializa se necessário
            if (!this.role || this.role === 'VENDEDOR' && this.usuarioId === null) {
                await this.inicializar();
            }

            // 👑 ADMIN = acesso total
            if (this.role === 'ADMIN') {
                console.log(`👑 ADMIN - Acesso total a ${slugModulo}`);
                return true;
            }

            // Define permissões por role
            const permissoes = {
                'GERENTE': [
                    'dashboard', 'pdv', 'produtos', 'estoque', 'vendas', 'caixas',
                    'clientes', 'fornecedores', 'controle-validade', 'comandas',
                    'pedidos-compra', 'contas-pagar', 'contas-receber', 'analise-financeira'
                ],
                'VENDEDOR': [
                    'dashboard', 'pdv', 'produtos', 'estoque', 'vendas', 
                    'caixas', 'clientes', 'controle-validade', 'comandas'
                ],
                'OPERADOR_CAIXA': [
                    'dashboard', 'pdv', 'vendas', 'caixas', 'clientes', 'comandas'
                ],
                'ESTOQUISTA': [
                    'dashboard', 'estoque', 'produtos', 'controle-validade', 'pedidos-compra'
                ],
                'COMPRADOR': [
                    'dashboard', 'estoque', 'produtos', 'fornecedores', 
                    'pedidos-compra', 'controle-validade'
                ],
                'APROVADOR': [
                    'dashboard', 'pedidos-compra', 'contas-pagar', 
                    'vendas', 'analise-financeira'
                ]
            };

            const modulosPermitidos = permissoes[this.role] || permissoes['VENDEDOR'];
            const temAcesso = modulosPermitidos.includes(slugModulo);

            if (temAcesso) {
                console.log(`✅ ${this.role} - Acesso OK a ${slugModulo}`);
            } else {
                console.log(`🔒 ${this.role} - Acesso negado a ${slugModulo}`);
            }

            return temAcesso;
        } catch (error) {
            console.error(`❌ Erro ao verificar permissão para ${slugModulo}:`, error);
            return false;
        }
    }

    /**
     * Verifica se pode executar uma ação
     */
    async verificarAcao(slugModulo, acao = 'pode_acessar') {
        try {
            // Apenas ADMIN e GERENTE podem criar/editar/deletar
            return ['ADMIN', 'GERENTE'].includes(this.role);
        } catch (error) {
            console.warn(`⚠️ Erro ao verificar ação ${acao}:`, error.message);
            return false;
        }
    }

    /**
     * Lista módulos disponíveis para o role
     */
    async obterModulosDisponiveis() {
        try {
            if (!this.role || this.role === 'VENDEDOR' && this.usuarioId === null) {
                await this.inicializar();
            }

            const permissoes = {
                'ADMIN': '*',
                'GERENTE': [
                    'dashboard', 'pdv', 'produtos', 'estoque', 'vendas', 'caixas',
                    'clientes', 'fornecedores', 'controle-validade', 'comandas',
                    'pedidos-compra', 'contas-pagar', 'contas-receber', 'analise-financeira'
                ],
                'VENDEDOR': [
                    'dashboard', 'pdv', 'produtos', 'estoque', 'vendas', 
                    'caixas', 'clientes', 'controle-validade', 'comandas'
                ],
                'OPERADOR_CAIXA': ['dashboard', 'pdv', 'vendas', 'caixas', 'clientes', 'comandas'],
                'ESTOQUISTA': ['dashboard', 'estoque', 'produtos', 'controle-validade', 'pedidos-compra'],
                'COMPRADOR': ['dashboard', 'estoque', 'produtos', 'fornecedores', 'pedidos-compra', 'controle-validade'],
                'APROVADOR': ['dashboard', 'pedidos-compra', 'contas-pagar', 'vendas', 'analise-financeira']
            };

            const modulosSlugs = permissoes[this.role] || permissoes[ 'VENDEDOR'];

            // Se é ADMIN, retorna todos
            if (modulosSlugs === '*') {
                const { data } = await window.supabase
                    .from('modulos')
                    .select('id, nome, slug, icone')
                    .eq('ativo', true);
                return data || [];
            }

            // Filtra pelos permitidos
            const { data } = await window.supabase
                .from('modulos')
                .select('id, nome, slug, icone')
                .eq('ativo', true)
                .in('slug', modulosSlugs);
            
            return data || [];
        } catch (error) {
            console.error('❌ Erro ao obter módulos disponíveis:', error);
            return [];
        }
    }
}

// Instância global
const permissaoManager = new PermissaoManager();

/**
 * Função auxiliar: Verifica acesso a um módulo
 * Inicializa o manager se necessário
 * @param {string} moduloSlug - Slug do módulo
 * @param {boolean} redirectOnDeny - Se deve redirecionar para dashboard se acesso negado
 * @returns {Promise<boolean>}
 */
async function verificarAcessoModulo(moduloSlug, redirectOnDeny = false) {
    try {
        // Inicializa se não foi inicializado
        if (!permissaoManager.usuarioId) {
            await permissaoManager.inicializar();
        }

        const temAcesso = await permissaoManager.podeAcessarModulo(moduloSlug);

        if (!temAcesso && redirectOnDeny) {
            console.warn(`❌ Acesso negado ao módulo: ${moduloSlug}`);
            showToast('❌ Você não tem permissão para acessar este módulo', 'error');
            setTimeout(() => {
                window.location.href = '/pages/dashboard.html';
            }, 1500);
            return false;
        }

        return temAcesso;
    } catch (error) {
        console.error('❌ Erro ao verificar acesso:', error);
        if (redirectOnDeny) {
            setTimeout(() => {
                window.location.href = '/pages/dashboard.html';
            }, 1500);
        }
        return false;
    }
}

/**
 * Função auxiliar: Verifica se usuário pode criar
 * @param {string} moduloSlug - Slug do módulo
 * @returns {Promise<boolean>}
 */
async function podeCriar(moduloSlug) {
    if (!permissaoManager.usuarioId) {
        await permissaoManager.inicializar();
    }
    return permissaoManager.verificarAcao(moduloSlug, 'pode_criar');
}

/**
 * Função auxiliar: Verifica se usuário pode editar
 * @param {string} moduloSlug - Slug do módulo
 * @returns {Promise<boolean>}
 */
async function podeEditar(moduloSlug) {
    if (!permissaoManager.usuarioId) {
        await permissaoManager.inicializar();
    }
    return permissaoManager.verificarAcao(moduloSlug, 'pode_editar');
}

/**
 * Função auxiliar: Verifica se usuário pode deletar
 * @param {string} moduloSlug - Slug do módulo
 * @returns {Promise<boolean>}
 */
async function podeDeletar(moduloSlug) {
    if (!permissaoManager.usuarioId) {
        await permissaoManager.inicializar();
    }
    return permissaoManager.verificarAcao(moduloSlug, 'pode_deletar');
}
