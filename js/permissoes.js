/**
 * Sistema de Permissões por Usuário Individual
 * Cada admin de empresa configura quais módulos cada usuário pode acessar
 */

class PermissaoManager {
    constructor() {
        this.usuarioId = null;
        this.empresaId = null;
        this.permissoesCache = {};
    }

    /**
     * Inicializa o manager com dados do usuário atual
     */
    async inicializar() {
        try {
            const user = await getCurrentUser();
            const empresa = await getEmpresaConfig();
            
            this.usuarioId = user?.id;
            this.empresaId = empresa?.id;
            
            if (!this.usuarioId || !this.empresaId) {
                console.warn('⚠️ PermissaoManager: Usuário ou empresa não inicializados');
                return false;
            }
            
            return true;
        } catch (error) {
            console.error('❌ Erro ao inicializar PermissaoManager:', error);
            return false;
        }
    }

    /**
     * Verifica se usuário pode acessar um módulo
     * Consulta a tabela usuarios_modulos
     * @param {string} slugModulo - Slug do módulo (ex: 'pdv', 'produtos')
     * @returns {Promise<boolean>}
     */
    async podeAcessarModulo(slugModulo) {
        if (!this.usuarioId || !this.empresaId) {
            console.warn('⚠️ PermissaoManager não inicializado, usando fallback');
            return this._verificarPermissaoLocal(slugModulo);
        }

        try {
            // Primeiro, encontra o módulo pelo slug
            const { data: modulo, error: erroModulo } = await window.supabase
                .from('modulos')
                .select('id')
                .eq('slug', slugModulo)
                .single();

            if (erroModulo || !modulo) {
                console.warn(`⚠️ Módulo ${slugModulo} não encontrado`);
                return this._verificarPermissaoLocal(slugModulo);
            }

            // Depois, verifica a permissão do usuário
            const { data, error } = await window.supabase
                .from('usuarios_modulos')
                .select('pode_acessar')
                .eq('empresa_id', this.empresaId)
                .eq('usuario_id', this.usuarioId)
                .eq('modulo_id', modulo.id)
                .maybeSingle();

            if (error && error.code !== 'PGRST116') {
                throw error;
            }

            // Se não tem registro, significa que não tem acesso
            return data?.pode_acessar === true;
        } catch (error) {
            console.warn(`⚠️ Erro ao verificar permissão para ${slugModulo}:`, error.message);
            return this._verificarPermissaoLocal(slugModulo);
        }
    }

    /**
     * Verifica se usuário pode executar uma ação em um módulo
     * @param {string} slugModulo - Slug do módulo
     * @param {string} acao - Ação ('pode_criar', 'pode_editar', 'pode_deletar')
     * @returns {Promise<boolean>}
     */
    async verificarAcao(slugModulo, acao = 'pode_acessar') {
        if (!this.usuarioId || !this.empresaId) {
            return false;
        }

        try {
            const { data: modulo } = await window.supabase
                .from('modulos')
                .select('id')
                .eq('slug', slugModulo)
                .single();

            if (!modulo) return false;

            const { data } = await window.supabase
                .from('usuarios_modulos')
                .select(acao)
                .eq('empresa_id', this.empresaId)
                .eq('usuario_id', this.usuarioId)
                .eq('modulo_id', modulo.id)
                .maybeSingle();

            return data && data[acao] === true;
        } catch (error) {
            console.warn(`⚠️ Erro ao verificar ação ${acao}:`, error.message);
            return false;
        }
    }

    /**
     * Obtém lista de módulos que usuário pode acessar
     * @returns {Promise<Array>}
     */
    async obterModulosDisponiveis() {
        if (!this.usuarioId || !this.empresaId) {
            return [];
        }

        try {
            const { data, error } = await window.supabase
                .from('usuarios_modulos')
                .select(`
                    modulo_id,
                    modulos(id, nome, slug, icone)
                `)
                .eq('empresa_id', this.empresaId)
                .eq('usuario_id', this.usuarioId)
                .eq('pode_acessar', true);

            if (error) throw error;

            return data?.map(item => item.modulos).filter(m => m) || [];
        } catch (error) {
            console.error('❌ Erro ao obter módulos disponíveis:', error);
            return [];
        }
    }

    /**
     * Fallback: Verifica permissão baseado no role do usuário
     * Usado quando a tabela de permissões individuais não está disponível
     * @private
     */
    async _verificarPermissaoLocal(slugModulo) {
        try {
            const user = await getCurrentUser();
            const role = user?.role || 'VENDEDOR';

            // Permissões padrão por role (fallback)
            const permissoes = {
                'ADMIN': ['*'], // Acesso total
                'VENDEDOR': ['dashboard', 'produtos', 'estoque', 'vendas', 'pdv', 'clientes'],
                'COMPRADOR': ['dashboard', 'produtos', 'fornecedores', 'pedidos-compra', 'estoque'],
                'APROVADOR': ['dashboard', 'analises-financeiras', 'pedidos-compra', 'estoque'],
                'GERENTE': ['dashboard', 'analises-financeiras', 'estoque', 'vendas'],
            };

            const modulosAcesso = permissoes[role] || [];
            return modulosAcesso.includes('*') || modulosAcesso.includes(slugModulo);
        } catch (error) {
            console.warn('⚠️ Erro no fallback de permissão:', error);
            return false;
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
        if (!permissaoManager.usuarioId || !permissaoManager.empresaId) {
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
    if (!permissaoManager.usuarioId || !permissaoManager.empresaId) {
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
    if (!permissaoManager.usuarioId || !permissaoManager.empresaId) {
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
    if (!permissaoManager.usuarioId || !permissaoManager.empresaId) {
        await permissaoManager.inicializar();
    }
    return permissaoManager.verificarAcao(moduloSlug, 'pode_deletar');
}
