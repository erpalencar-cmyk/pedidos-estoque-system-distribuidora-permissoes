-- =====================================================
-- SCRIPT DE VERIFICAÇÃO COMPLETA
-- =====================================================
-- Execute isto para ver exatamente qual é o problema

-- 1. VER EMPRESA
SELECT 'EMPRESA:' as secao;
SELECT id, nome, cnpj FROM empresas WHERE cnpj = '12.345.678/0001-99';

-- 2. VER ADMIN
SELECT 'ADMIN:' as secao;
SELECT id, email, empresa_id FROM admin_users WHERE email = 'brunoallencar@hotmail.com';

-- 3. VER VÍNCULO COMPLETO
SELECT 'VÍNCULO COMPLETO:' as secao;
SELECT 
    au.email,
    au.empresa_id,
    e.nome,
    e.cnpj,
    e.supabase_url
FROM admin_users au
LEFT JOIN empresas e ON au.empresa_id = e.id
WHERE au.email = 'brunoallencar@hotmail.com';

-- 4. VER SE EMPRESA_ID NÃO É NULL
SELECT 'VERIFICAR NULIDADE:' as secao;
SELECT 
    email,
    CASE WHEN empresa_id IS NULL THEN 'NULO ❌' ELSE 'OK ✅' END as empresa_id_status
FROM admin_users 
WHERE email = 'brunoallencar@hotmail.com';
