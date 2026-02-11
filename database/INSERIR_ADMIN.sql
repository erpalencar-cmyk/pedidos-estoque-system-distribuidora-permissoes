-- =====================================================
-- SCRIPT: INSERIR ADMIN E EMPRESA (se não existirem)
-- =====================================================
-- Execute no SQL Editor: https://btdqhrmbnvhhxeessplc.supabase.co/project/default/editor
-- Ctrl+Enter ou clique em "Run"

-- =====================================================
-- 1. CRIAR EMPRESA (se não existir)
-- =====================================================

INSERT INTO public.empresas (nome, cnpj, supabase_url, supabase_anon_key)
VALUES (
    'Distribuidora Bruno Allencar',
    '12.345.678/0001-99',
    'https://uyyyxblwffzonczrtqjy.supabase.co',
    'sb_publishable_uGN5emN1tfqTgTudDZJM-g_Qc4YKIj_'
)
ON CONFLICT (cnpj) DO NOTHING;

-- =====================================================
-- 2. CRIAR ADMIN_USER
-- =====================================================

INSERT INTO public.admin_users (email, empresa_id)
SELECT 
    'brunoallencar@hotmail.com',
    id 
FROM public.empresas 
WHERE cnpj = '12.345.678/0001-99'
ON CONFLICT (email) DO NOTHING;

-- =====================================================
-- 3. VERIFICAR (execute estes SELECTs)
-- =====================================================

-- Ver empresas
SELECT id, nome, cnpj FROM public.empresas;

-- Ver admins
SELECT id, email, empresa_id FROM public.admin_users;

-- Ver se o email existe
SELECT email, empresa_id FROM public.admin_users WHERE email = 'brunoallencar@hotmail.com';
