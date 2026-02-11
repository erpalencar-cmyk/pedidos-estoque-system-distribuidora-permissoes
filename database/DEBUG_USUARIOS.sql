-- Script de Debug: Verificar dados de usuário
-- Execute no Supabase SQL Editor para ver os dados exatos do usuário

-- Verificar todos os usuários e seus status
SELECT 
    id,
    email,
    nome_completo,
    role,
    ativo,
    email_confirmado,
    approved,
    approved_by,
    approved_at,
    created_at
FROM public.users
ORDER BY created_at DESC
LIMIT 10;

-- Se tiver um email específico, use:
-- SELECT * FROM public.users WHERE email = 'seu-email@example.com';
