/**
 * Sistema de Permissões por Usuário Individual
 * Cada admin de empresa configura quais módulos cada usuário pode acessar.
 * 
 * NOTA: Como cada empresa tem seu próprio banco Supabase,
 * não é necessário filtrar por empresa_id — os dados já são isolados por projeto.
 */

class PermissaoManager {
    constructor() {
        this.usuarioId = null;
        this.userRole = null;
        this._cachePermissoes = null; // Cache: { slug: { pode_acessar, pode_criar, pode_editar, pode_deletar } }
        this._cacheTimestamp = 0;
        this._cacheTTL = 60000; // 1 minuto de cache
    }

    /**
     * Inicializa o manager com dados do usuário atual
     */
    async inicializar() {
        try {
            const user = await getCurrentUser();
            
            this.usuarioId = user?.id;
            this.userRole = (user?.role || '').toUpperCase();
            
            if (!this.usuarioId) {
                console.warn('⚠️ PermissaoManager: Usuário não autenticado');
                return false;
            }
            
            return true;
        } catch (error) {
            console.error('❌ Erro ao inicializar PermissaoManager:', error);
            return false;
        }
    }

    /**
     * Verifica se o usuário é ADMIN (acesso total)
     */
    isAdmin() {
        return this.userRole === 'ADMIN' || this.userRole === 'ADMINISTRADOR';
    }

    /**
     * Invalida o cache de permissões (útil após salvar permissões)
     */
    invalidarCache() {
        this._cachePermissoes = null;
        this._cacheTimestamp = 0;
    }

    /**
     * Carrega todas as permissões do usuário de uma vez (com cache)
     * @returns {Promise<Object>} Mapa de slug → permissões
     */
    async _carregarPermissoes() {
        // Retornar do cache se válido
        if (this._cachePermissoes && (Date.now() - this._cacheTimestamp) < this._cacheTTL) {
            return this._cachePermissoes;
        }

        if (!this.usuarioId) return {};

        try {
            const { data, error } = await window.supabase
                .from('usuarios_modulos')
                .select(`
                    pode_acessar,
                    pode_criar,
                    pode_editar,
                    pode_deletar,
                    modulos(slug)
                `)
                .eq('usuario_id', this.usuarioId);

            if (error) throw error;

            const cache = {};
            (data || []).forEach(item => {
                const slug = item.modulos?.slug;
                if (slug) {
                    cache[slug] = {
                        pode_acessar: item.pode_acessar === true,
                        pode_criar: item.pode_criar === true,
                        pode_editar: item.pode_editar === true,
                        pode_deletar: item.pode_deletar === true
                    };
                }
            });

            this._cachePermissoes = cache;
            this._cacheTimestamp = Date.now();
            return cache;
        } catch (error) {
            console.error('❌ Erro ao carregar permissões:', error);
            return {};
        }
    }

    /**
     * Verifica se usuário pode acessar um módulo
     * @param {string} slugModulo - Slug do módulo (ex: 'pdv', 'produtos')
     * @returns {Promise<boolean>}
     */
    async podeAcessarModulo(slugModulo) {
        if (!this.usuarioId) {
            await this.inicializar();
        }

        // ADMIN tem acesso total
        if (this.isAdmin()) return true;

        // Dashboard é sempre acessível
        if (slugModulo === 'dashboard') return true;

        try {
            const permissoes = await this._carregarPermissoes();
            return permissoes[slugModulo]?.pode_acessar === true;
        } catch (error) {
            console.warn(`⚠️ Erro ao verificar permissão para ${slugModulo}:`, error.message);
            return false;
        }
    }

    /**
     * Verifica se usuário pode executar uma ação em um módulo
     * @param {string} slugModulo - Slug do módulo
     * @param {string} acao - Ação ('pode_criar', 'pode_editar', 'pode_deletar')
     * @returns {Promise<boolean>}
     */
    async verificarAcao(slugModulo, acao = 'pode_acessar') {
        if (!this.usuarioId) {
            await this.inicializar();
        }

        // ADMIN pode tudo
        if (this.isAdmin()) return true;

        try {
            const permissoes = await this._carregarPermissoes();
            return permissoes[slugModulo]?.[acao] === true;
        } catch (error) {
            console.warn(`⚠️ Erro ao verificar ação ${acao}:`, error.message);
            return false;
        }
    }

    /**
     * Obtém lista de slugs de módulos que o usuário pode acessar
     * @returns {Promise<string[]>}
     */
    async obterSlugsPermitidos() {
        if (!this.usuarioId) {
            await this.inicializar();
        }

        // ADMIN: retorna ['*'] para indicar acesso total
        if (this.isAdmin()) return ['*'];

        try {
            const permissoes = await this._carregarPermissoes();
            const slugs = ['dashboard']; // Dashboard sempre acessível
            
            Object.entries(permissoes).forEach(([slug, perm]) => {
                if (perm.pode_acessar) {
                    slugs.push(slug);
                }
            });

            return slugs;
        } catch (error) {
            console.error('❌ Erro ao obter slugs permitidos:', error);
            return ['dashboard'];
        }
    }

    /**
     * Obtém lista de módulos que usuário pode acessar (com dados completos)
     * @returns {Promise<Array>}
     */
    async obterModulosDisponiveis() {
        if (!this.usuarioId) {
            await this.inicializar();
        }

        try {
            if (this.isAdmin()) {
                // ADMIN: retorna todos os módulos ativos
                const { data, error } = await window.supabase
                    .from('modulos')
                    .select('id, nome, slug, icone')
                    .eq('ativo', true)
                    .order('ordem');
                if (error) throw error;
                return data || [];
            }

            const { data, error } = await window.supabase
                .from('usuarios_modulos')
                .select(`
                    modulo_id,
                    modulos(id, nome, slug, icone)
                `)
                .eq('usuario_id', this.usuarioId)
                .eq('pode_acessar', true);

            if (error) throw error;

            return data?.map(item => item.modulos).filter(m => m) || [];
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
