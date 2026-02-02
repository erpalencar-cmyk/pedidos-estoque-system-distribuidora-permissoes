// =====================================================
// CONFIGURAÇÃO DO SUPABASE
// =====================================================

// IMPORTANTE: Substitua com suas credenciais do Supabase
const SUPABASE_URL = 'https://uyyyxblwffzonczrtqjy.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_uGN5emN1tfqTgTudDZJM-g_Qc4YKIj_';

// Inicializar cliente Supabase e exportar para uso global
// A biblioteca Supabase CDN expõe o namespace em window.supabase
const { createClient } = window.supabase;
window.supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
