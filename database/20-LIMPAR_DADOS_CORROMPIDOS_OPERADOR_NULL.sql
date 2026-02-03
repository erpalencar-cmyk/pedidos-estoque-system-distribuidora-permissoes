-- Script para limpar dados corrompidos em caixa_sessoes
-- Remove registros com operador_id NULL ou status inválido
-- IMPORTANTE: Delete em cascata para respeitar foreign keys

-- Passo 1: Verificar quantos registros corrompidos existem
SELECT COUNT(*) as registros_com_operador_null 
FROM caixa_sessoes 
WHERE operador_id IS NULL;

-- Passo 2: Ver os registros corrompidos
SELECT id, caixa_id, operador_id, status, data_abertura, data_fechamento
FROM caixa_sessoes 
WHERE operador_id IS NULL
ORDER BY data_abertura DESC;

-- Passo 3a: Deletar vendas_itens das vendas que referenciam caixa_sessoes com operador_id NULL
DELETE FROM vendas_itens 
WHERE venda_id IN (
    SELECT v.id 
    FROM vendas v
    WHERE v.movimentacao_caixa_id IN (
        SELECT id FROM caixa_sessoes WHERE operador_id IS NULL
    )
);

-- Passo 3b: Deletar vendas que referenciam caixa_sessoes com operador_id NULL
DELETE FROM vendas 
WHERE movimentacao_caixa_id IN (
    SELECT id FROM caixa_sessoes WHERE operador_id IS NULL
);

-- Passo 3c: DELETAR registros com operador_id NULL
DELETE FROM caixa_sessoes 
WHERE operador_id IS NULL;

-- Passo 4: Verificar se há outros registros inválidos (status que não é ABERTO ou FECHADO)
SELECT COUNT(*) as registros_status_invalido
FROM caixa_sessoes 
WHERE status NOT IN ('ABERTO', 'FECHADO');

-- Passo 5: Corrigir registros com status inválido (não deletar, apenas corrigir)
UPDATE caixa_sessoes 
SET status = 'FECHADO' 
WHERE status NOT IN ('ABERTO', 'FECHADO');

-- Passo 6: Verificar se há registros ABERTO sem data de fechamento (ok) 
-- e FECHADO com data de fechamento (ok)
SELECT 
    id, 
    status,
    data_abertura,
    data_fechamento,
    CASE 
        WHEN status = 'ABERTO' AND data_fechamento IS NOT NULL THEN '❌ ERRO: ABERTO mas com data_fechamento'
        WHEN status = 'FECHADO' AND data_fechamento IS NULL THEN '❌ ERRO: FECHADO mas sem data_fechamento'
        WHEN status = 'ABERTO' AND data_fechamento IS NULL THEN '✅ OK: ABERTO corretamente'
        WHEN status = 'FECHADO' AND data_fechamento IS NOT NULL THEN '✅ OK: FECHADO corretamente'
        ELSE '❓ DESCONHECIDO'
    END as validacao
FROM caixa_sessoes
ORDER BY data_abertura DESC;

-- Passo 7: Corrigir registros ABERTO que têm data_fechamento (trocar para FECHADO)
UPDATE caixa_sessoes 
SET status = 'FECHADO' 
WHERE status = 'ABERTO' AND data_fechamento IS NOT NULL;

-- Passo 8: Verificação final
SELECT 
    COUNT(*) as total_registros,
    SUM(CASE WHEN status = 'ABERTO' THEN 1 ELSE 0 END) as abertos,
    SUM(CASE WHEN status = 'FECHADO' THEN 1 ELSE 0 END) as fechados,
    SUM(CASE WHEN operador_id IS NULL THEN 1 ELSE 0 END) as operador_null
FROM caixa_sessoes;

SELECT 'Limpeza concluída com sucesso!' as resultado;
