-- =====================================================
-- VERIFICAR DADOS (Execute isto untuk confirmar setup)
-- =====================================================

-- 1. Ver todas as empresas cadastradas
SELECT 
    id,
    nome,
    cnpj,
    supabase_url,
    created_at
FROM empresas;

-- 2. Ver todos os admins vinculados
SELECT 
    au.email,
    au.empresa_id,
    e.nome as empresa_nome,
    e.cnpj,
    au.created_at
FROM admin_users au
JOIN empresas e ON au.empresa_id = e.id;

-- 3. Verificar se existe admin vinculado a empresa
SELECT * FROM admin_users WHERE email = 'brunoallencar@hotmail.com';

-- 4. Verificar se empresa existe
SELECT * FROM empresas WHERE cnpj = '12.345.678/0001-99';
