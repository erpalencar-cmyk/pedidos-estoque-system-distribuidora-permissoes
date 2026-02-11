// =====================================================
// CONFIGURAÇÃO CENTRAL DO SUPABASE (Banco de Empresas)
// =====================================================

// Credenciais Banco Central - TODAS AS EMPRESAS
const CENTRAL_SUPABASE_URL = 'https://btdqhrmbnvhhxeessplc.supabase.co';
const CENTRAL_SUPABASE_ANON_KEY = 'sb_publishable_IAVaf7Er3VH_9DEB2kXlaQ_0_jLSO9-';

// Variáveis dinâmicas para empresa selecionada
let CURRENT_EMPRESA_ID = null;
let CURRENT_EMPRESA = null;
let CURRENT_SUPABASE = null;
let supabaseCentral = null;

// Guardar referência à biblioteca original (antes de sobrescrever window.supabase)
let supabaseLib = null;

// Flag de inicialização
let inicializacaoEmAndamento = false;

// =====================================================
// INICIALIZAR SUPABASE QUANDO A BIBLIOTECA ESTIVER PRONTA
// =====================================================

function inicializarSupabase() {
    if (inicializacaoEmAndamento) {
        console.log('⏳ Inicialização já em andamento, aguardando...');
        return;
    }
    
    inicializacaoEmAndamento = true;
    
    if (!window.supabase) {
        console.error('❌ Biblioteca Supabase não carregada!');
        inicializacaoEmAndamento = false;
        return;
    }

    // Guardar referência à biblioteca original
    supabaseLib = window.supabase;
    
    const { createClient } = supabaseLib;
    
    supabaseCentral = createClient(CENTRAL_SUPABASE_URL, CENTRAL_SUPABASE_ANON_KEY, {
        auth: {
            persistSession: true,
            autoRefreshToken: true,
            detectSessionInUrl: true
        }
    });
    
    window.supabaseCentral = supabaseCentral;
    console.log('✅ Supabase Central inicializado - Banco de Empresas');
    
    // CRÍTICO: Restaurar empresa do localStorage IMEDIATAMENTE (sincronamente)
    restaurarEmpresaImediatamente();
    
    // Se ainda não restaurou, tentar novamente com pequeno atraso
    if (!CURRENT_SUPABASE) {
        setTimeout(() => {
            if (!CURRENT_SUPABASE) {
                console.log('⏳ Segunda tentativa de restauração de empresa...');
                restaurarEmpresaImediatamente();
            }
        }, 100);
    }
    
    inicializacaoEmAndamento = false;
}

// Inicializar assim que possível
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', inicializarSupabase);
} else {
    inicializarSupabase();
}

// =====================================================
// RESTAURAÇÃO IMEDIATA DE EMPRESA (Síncrono)
// =====================================================

function restaurarEmpresaImediatamente() {
    try {
        let empresaJson = null;
        
        // Tentar recuperar do localStorage COM SEGURANÇA
        try {
            // Verificar se localStorage está disponível
            if (typeof localStorage !== 'undefined' && localStorage !== null) {
                empresaJson = localStorage.getItem('empresaAtual');
            } else {
                console.warn('⚠️ localStorage não disponível (possível iframe ou contexto restrito)');
            }
        } catch (e) {
            console.warn('⚠️ Erro ao acessar localStorage:', e.message);
            // Usar sessionStorage como fallback
            try {
                if (typeof sessionStorage !== 'undefined' && sessionStorage !== null) {
                    empresaJson = sessionStorage.getItem('empresaAtual');
                    if (empresaJson) console.log('✅ Usando sessionStorage para empresa');
                }
            } catch (e2) {
                console.warn('⚠️ sessionStorage também indisponível');
            }
        }
        
        if (empresaJson && supabaseLib) {
            try {
                const empresa = JSON.parse(empresaJson);
                CURRENT_EMPRESA = empresa;
                CURRENT_EMPRESA_ID = empresa.id;
                
                // Criar cliente da empresa IMEDIATAMENTE
                if (empresa.supabase_url && empresa.supabase_anon_key) {
                    const { createClient } = supabaseLib;
                    CURRENT_SUPABASE = createClient(
                        empresa.supabase_url,
                        empresa.supabase_anon_key
                    );
                    
                    // CRÍTICO: Sobrescrever window.supabase com cliente da empresa
                    window.supabase = CURRENT_SUPABASE;
                    
                    console.log(`✅ Empresa restaurada IMEDIATAMENTE: ${empresa.nome}`);
                    console.log(`✅ window.supabase agora aponta para a empresa`);
                    return true; // Sucesso
                }
            } catch (parseError) {
                console.warn('⚠️ Erro ao fazer parse da empresa:', parseError.message);
            }
        } else {
            if (!empresaJson) {
                console.log('ℹ️  Nenhuma empresa armazenada (primeira vez no login)');
            }
            if (!supabaseLib) {
                console.warn('⚠️ supabaseLib ainda não disponível');
            }
        }
        
        return false; // Falha ou sem dados
    } catch (error) {
        console.warn('⚠️ Erro ao restaurar empresa imediatamente:', error.message);
        return false;
    }
}

// =====================================================
// FUNÇÕES DE GERENCIAMENTO DE EMPRESA
// =====================================================

// Aguardar supabase estar pronto
async function aguardarSupabase() {
    let tentativas = 0;
    while (!supabaseCentral && tentativas < 50) {
        await new Promise(resolve => setTimeout(resolve, 100));
        tentativas++;
    }
    if (!supabaseCentral) {
        throw new Error('Supabase central não conseguiu inicializar');
    }
    
    // Se há dados de empresa no localStorage, restaurar agora
    try {
        const empresaJson = localStorage.getItem('empresaAtual');
        if (empresaJson && !CURRENT_SUPABASE) {
            const empresa = JSON.parse(empresaJson);
            CURRENT_EMPRESA = empresa;
            CURRENT_EMPRESA_ID = empresa.id;
            
            if (empresa.supabase_url && empresa.supabase_anon_key && supabaseLib) {
                const { createClient } = supabaseLib;
                CURRENT_SUPABASE = createClient(
                    empresa.supabase_url,
                    empresa.supabase_anon_key
                );
                console.log(`✅ Cliente da empresa '${empresa.nome}' restaurado`);
                
                // IMPORTANTE: Sobrescrever window.supabase com o cliente da empresa
                window.supabase = CURRENT_SUPABASE;
                console.log(`✅ window.supabase agora aponta para a empresa`);
            }
        }
    } catch (e) {
        console.warn('⚠️ Erro ao restaurar empresa do localStorage:', e.message);
    }
}

async function carregarEmpresa(empresaId) {
    try {
        // NÃO aguardar aguardarClientePronto() aqui - causaria loop circular
        // carregarEmpresa() é chamado ANTES de window.supabase estar pronto
        // Usar supabaseCentral que já está inicializado
        
        // Aguardar apenas supabaseCentral estar pronto
        let tentativas = 0;
        while (!supabaseCentral && tentativas < 100) {
            await new Promise(r => setTimeout(r, 50));
            tentativas++;
        }
        
        if (!supabaseCentral) {
            throw new Error('Supabase Central não ficou pronto em tempo hábil');
        }
        
        console.log(`🔄 Carregando dados da empresa: ${empresaId}`);
        
        // Usar supabaseCentral
        const client = supabaseCentral;
        if (!client) {
            throw new Error('Supabase não inicializado. Tente recarregar a página.');
        }
        
        // Buscar configurações da empresa no banco central
        const { data: empresasArray, error } = await client
            .from('empresas')
            .select('*')
            .eq('id', empresaId)
            .limit(1);
        
        if (error) throw error;
        if (!empresasArray || empresasArray.length === 0) throw new Error('Empresa não encontrada');
        
        const data = empresasArray[0];
        
        CURRENT_EMPRESA_ID = empresaId;
        CURRENT_EMPRESA = data;
        
        // Armazenar no localStorage para acesso rápido (com segurança)
        try {
            localStorage.setItem('empresaId', empresaId);
            localStorage.setItem('empresaAtual', JSON.stringify(data));
        } catch (e) {
            console.warn('⚠️ localStorage não disponível, usando apenas memória:', e.message);
        }
        
        // Inicializar Supabase da empresa
        if (data.supabase_url && data.supabase_anon_key && supabaseLib) {
            const { createClient } = supabaseLib;
            CURRENT_SUPABASE = createClient(
                data.supabase_url,
                data.supabase_anon_key,
                {
                    auth: {
                        persistSession: true,
                        autoRefreshToken: true,
                        detectSessionInUrl: true
                    }
                }
            );
            
            // IMPORTANTE: Sobrescrever window.supabase com o cliente da empresa
            window.supabase = CURRENT_SUPABASE;
            
            console.log(`✅ Supabase da empresa ${data.nome} inicializado`);
            console.log(`✅ window.supabase agora aponta para a empresa`);
        }
        
        return data;
    } catch (error) {
        console.error('❌ Erro ao carregar empresa:', error.message);
        throw error;
    }
}

// =====================================================
// AGUARDAR CLIENTE PRONTO (Para páginas internas)
// =====================================================
// Qualquer página que depende de window.supabase deve chamar isso

async function aguardarClientePronto() {
    let tentativas = 0;
    const maxTentativas = 100;
    
    while (tentativas < maxTentativas) {
        // Se window.supabase tem .from(), está pronto
        if (window.supabase && typeof window.supabase.from === 'function') {
            console.log('✅ Cliente Supabase pronto!');
            return true;
        }
        
        // Aguardar um pouco e tentar novamente
        await new Promise(r => setTimeout(r, 50));
        tentativas++;
    }
    
    console.error('❌ Timeout aguardando cliente Supabase');
    throw new Error('Cliente Supabase não ficou pronto em tempo hábil');
}

