-- ================================================================
-- INSERIR USUÁRIO EXISTENTE NO AUTH NA TABELA USERS
-- ================================================================
-- Data: Fevereiro 3, 2026
-- Propósito: Registrar usuário que já existe no Supabase Auth
--           mas não está na tabela users
-- ================================================================

-- ⚠️ SUBSTITUA O ID E EMAIL PELOS DADOS DO SEU USUÁRIO

INSERT INTO users (
    id,
    email,
    nome_completo,
    role,
    ativo,
    email_confirmado,
    created_at,
    updated_at
)
VALUES (
    '95a5a423-05ef-42b1-a75d-50bcced319c7',  -- ← ID do usuário no Auth
    'brunoallencar@hotmail.com',               -- ← Email do usuário
    'Bruno Allencar',                          -- ← Nome completo
    'ADMIN'::user_role,                        -- ← Role
    true,                                      -- ← Ativo
    true,                                      -- ← Email confirmado
    NOW(),
    NOW()
)
ON CONFLICT (id) DO UPDATE
    SET 
        email = 'brunoallencar@hotmail.com',
        nome_completo = 'Bruno Allencar',
        role = 'ADMIN'::user_role,
        ativo = true,
        email_confirmado = true,
        updated_at = NOW();

-- Verificar inserção
SELECT id, email, nome_completo, role, ativo 
FROM users 
WHERE id = '95a5a423-05ef-42b1-a75d-50bcced319c7';

-- ================================================================
-- ✅ PRONTO - USUÁRIO REGISTRADO NA TABELA
-- ================================================================

/*
O usuário agora existe na tabela users e conseguirá fazer login.

Se ainda tiver erro 406, verifique:
1. O ID está correto? (copie exatamente do erro)
2. O email está correto?
3. Execute a query SELECT acima para confirmar que foi inserido

Se precisar inserir VÁRIOS usuários que já existem no Auth,
use a query abaixo (descomente):
*/

-- PARA INSERIR MÚLTIPLOS USUÁRIOS EXISTENTES:
/*
-- Primeiro, você precisa dos IDs dos usuários no Supabase Auth
-- Vá em: https://app.supabase.com/ → Authentication → Users
-- Copie o ID (UUID) de cada usuário

-- Depois, execute:
INSERT INTO users (id, email, nome_completo, role, ativo, email_confirmado, created_at, updated_at)
VALUES
    ('ID-do-usuario-1', 'email1@example.com', 'Nome 1', 'ADMIN'::user_role, true, true, NOW(), NOW()),
    ('ID-do-usuario-2', 'email2@example.com', 'Nome 2', 'GERENTE'::user_role, true, true, NOW(), NOW()),
    ('ID-do-usuario-3', 'email3@example.com', 'Nome 3', 'OPERADOR_CAIXA'::user_role, true, true, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
*/

COMMIT;
