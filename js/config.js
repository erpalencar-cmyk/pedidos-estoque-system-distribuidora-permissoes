// =====================================================
// CONFIGURAÇÃO DO SUPABASE
// =====================================================

// Credenciais do Supabase
const SUPABASE_URL = 'https://uyyyxblwffzonczrtqjy.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_uGN5emN1tfqTgTudDZJM-g_Qc4YKIj_';

// Storage personalizado que funciona em qualquer contexto
const memoryStorage = {
    data: {},
    getItem(key) { 
        return this.data[key] || null; 
    },
    setItem(key, value) { 
        this.data[key] = value; 
    },
    removeItem(key) { 
        delete this.data[key]; 
    }
};

// Verificar se localStorage está disponível
function isStorageAvailable() {
    try {
        // Primeira verificação: typeof e null check
        if (typeof localStorage === 'undefined' || localStorage === null) {
            console.warn('⚠️ localStorage é undefined');
            return false;
        }
        
        // Segunda verificação: tentar acessar com proteção dupla
        const test = '__storage_test__';
        try {
            localStorage.setItem(test, test);
            localStorage.removeItem(test);
            console.log('✅ localStorage disponível');
            return true;
        } catch (storageError) {
            // Pode ser QuotaExceededError, NotAllowedError, SecurityError, etc
            console.warn('⚠️ localStorage não disponível:', storageError.name, '-', storageError.message);
            return false;
        }
    } catch (e) {
        // Captura TODOS os erros, incluindo "Access to storage is not allowed from this context"
        console.warn('⚠️ Erro ao verificar localStorage (contexto não permitido ou similar):', e.name, '-', e.message);
        return false;
    }
}

// Usar memoryStorage sempre como fallback seguro
const storage = memoryStorage;

// Inicializar cliente Supabase
try {
    // Verificar se a biblioteca foi carregada
    if (typeof window.supabase === 'undefined' || !window.supabase.createClient) {
        throw new Error('Biblioteca Supabase não carregada. Aguardando...');
    }
    
    const { createClient } = window.supabase;
    
    const options = {
        auth: {
            persistSession: true,
            autoRefreshToken: true,
            detectSessionInUrl: true
        }
    };
    
    // Criar cliente Supabase
    window.supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, options);
    console.log('✅ Supabase client inicializado');
    
} catch (error) {
    console.error('❌ Erro ao inicializar Supabase:', error.message);
}
