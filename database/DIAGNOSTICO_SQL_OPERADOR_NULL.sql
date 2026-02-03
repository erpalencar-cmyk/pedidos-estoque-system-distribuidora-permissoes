-- =====================================================
-- DIAGNÓSTICO - Verificar inserção de operador_id
-- =====================================================
-- Execute este script no Supabase SQL Editor

-- 1. Verificar a tabela caixa_sessoes
SELECT COUNT(*) as total_registros, 
       COUNT(*) FILTER (WHERE operador_id IS NULL) as com_operador_null,
       COUNT(*) FILTER (WHERE operador_id IS NOT NULL) as com_operador_valido
FROM caixa_sessoes;

-- 2. Mostrar os últimos 10 registros (deve mostrar NULL)
SELECT 
    id,
    caixa_id,
    operador_id,
    status,
    data_abertura,
    valor_abertura
FROM caixa_sessoes
ORDER BY data_abertura DESC
LIMIT 10;

-- 3. Se houver registros com NULL, ver qual é a causa
SELECT 
    *
FROM caixa_sessoes
WHERE operador_id IS NULL
LIMIT 5;

-- 4. Teste de inserção simples (SUBSTITUA com seu UUID real)
-- Primeiro, obtenha seu UUID da tabela users
SELECT id, email, full_name
FROM users
WHERE active = true
LIMIT 1;

-- 5. Agora tente inserir manualmente com o UUID encontrado
-- Descomente e execute (troque 'seu-uuid-aqui' com o UUID real):
/*
INSERT INTO caixa_sessoes (
    caixa_id, 
    operador_id, 
    valor_abertura, 
    status
) 
VALUES (
    (SELECT id FROM caixas LIMIT 1),  -- Primeiro caixa disponível
    'seu-uuid-aqui',                   -- Seu UUID do passo 4
    100.00,
    'ABERTO'
)
RETURNING *;
*/

-- 6. Se a inserção funcionar aqui, o problema está no lado do cliente
-- Se não funcionar, haverá uma mensagem de erro

-- 7. Verificar se há algum trigger que possa estar limpando
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table
FROM information_schema.triggers
WHERE event_object_table = 'caixa_sessoes';

-- 8. Se houver triggers, ver qual é a ação
SELECT pg_get_triggerdef(oid)
FROM pg_trigger
WHERE tgrelid = 'caixa_sessoes'::regclass;
