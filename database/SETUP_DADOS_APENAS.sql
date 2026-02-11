-- =====================================================
-- SCRIPT RÁPIDO: APENAS INSERIR DADOS
-- =====================================================
-- Use este script se já rodar SETUP_RAPIDO.sql uma vez
-- e quer adicionar mais empresas ou admins

-- =====================================================
-- INSERIR EMPRESA (se não existir)
-- =====================================================

INSERT INTO empresas (nome, cnpj, supabase_url, supabase_anon_key)
VALUES (
    'Distribuidora Bruno Allencar',
    '12.345.678/0001-99',
    'https://uyyyxblwffzonczrtqjy.supabase.co',
    'sb_publishable_uGN5emN1tfqTgTudDZJM-g_Qc4YKIj_'
)
ON CONFLICT (cnpj) DO NOTHING;

-- =====================================================
-- INSERIR ADMIN (se não existir)
-- =====================================================

INSERT INTO admin_users (email, empresa_id)
SELECT 
    'brunoallencar@hotmail.com',
    id 
FROM empresas 
WHERE cnpj = '12.345.678/0001-99'
ON CONFLICT (email) DO NOTHING;

-- =====================================================
-- VERIFICAR DADOS
-- =====================================================

SELECT 'Empresas criadas:' as status;
SELECT id, nome, cnpj FROM empresas;

SELECT 'Admins vinculados:' as status;
SELECT email, empresa_id FROM admin_users;
