-- =====================================================
-- SCRIPT: Corrigir Status de Vendas
-- =====================================================
-- 
-- PROBLEMA: Vendas aparecem como FINALIZADA na listagem
-- mas na verdade foram canceladas
--
-- CAUSA: Antes da correção, o sistema finalizava a venda
-- ANTES de emitir a nota. Se a nota falhasse, a venda
-- ficava FINALIZADA sem nota.
--
-- SOLUÇÃO: Este script identifica e corrige vendas
-- que estão FINALIZADAS mas sem nota fiscal ou com
-- estoque devolvido (indicando cancelamento)
-- =====================================================

-- ========== PASSO 1: VERIFICAR PROBLEMA ==========
-- Ver vendas FINALIZADAS sem nota fiscal
SELECT 
    id,
    numero,
    status,
    status_fiscal,
    nfce_chave,
    total,
    created_at,
    CASE 
        WHEN status = 'FINALIZADA' AND (status_fiscal IS NULL OR status_fiscal = '') THEN '⚠️ SEM NOTA'
        WHEN status = 'FINALIZADA' AND status_fiscal = 'EMITIDA_NFCE' THEN '✅ OK'
        ELSE status
    END as situacao
FROM vendas
WHERE status = 'FINALIZADA'
ORDER BY created_at DESC
LIMIT 50;

-- ========== PASSO 2: VERIFICAR MOVIMENTAÇÕES ==========
-- Verificar se o estoque foi devolvido (indicando cancelamento)
SELECT 
    v.id,
    v.numero,
    v.status,
    v.total,
    COUNT(CASE WHEN em.tipo_movimento = 'ENTRADA_DEVOLUCAO' THEN 1 END) as devolucoes,
    COUNT(CASE WHEN em.tipo_movimento = 'SAIDA_VENDA' THEN 1 END) as saidas
FROM vendas v
LEFT JOIN estoque_movimentacoes em ON em.referencia_id = v.id::text AND em.referencia_tipo IN ('VENDA', 'VENDA_CANCELADA')
WHERE v.status = 'FINALIZADA'
GROUP BY v.id, v.numero, v.status, v.total
HAVING COUNT(CASE WHEN em.tipo_movimento = 'ENTRADA_DEVOLUCAO' THEN 1 END) > 0
ORDER BY v.created_at DESC;

-- ========== PASSO 3: CORRIGIR STATUS (CUIDADO!) ==========
-- ⚠️ ATENÇÃO: Só execute se tiver certeza que as vendas devem ser canceladas!
-- Este comando atualiza vendas FINALIZADAS sem nota para CANCELADO

-- Descomente as linhas abaixo para executar a correção:

-- UPDATE vendas
-- SET status = 'CANCELADO'
-- WHERE status = 'FINALIZADA'
--   AND (status_fiscal IS NULL OR status_fiscal = '')
--   AND id IN (
--     SELECT v.id
--     FROM vendas v
--     LEFT JOIN estoque_movimentacoes em ON em.referencia_id = v.id::text 
--     WHERE em.referencia_tipo = 'VENDA_CANCELADA'
--        OR em.tipo_movimento = 'ENTRADA_DEVOLUCAO'
--   );

-- ========== PASSO 4: CORRIGIR VENDAS ESPECÍFICAS ==========
-- Se quiser corrigir apenas vendas específicas, use:

-- UPDATE vendas 
-- SET status = 'CANCELADO'
-- WHERE numero IN ('PED-20260205-367607', 'PED-20260205-510407');

-- ========== PASSO 5: VERIFICAR RESULTADO ==========
-- Após executar a correção, verifique:

SELECT 
    status,
    COUNT(*) as quantidade,
    SUM(total) as total_valor
FROM vendas
GROUP BY status
ORDER BY status;

-- =====================================================
-- EXPLICAÇÃO DOS STATUS:
-- =====================================================
-- RASCUNHO    - Venda iniciada, não finalizada
-- FINALIZADA  - Venda concluída, estoque baixado
-- CANCELADO   - Venda cancelada, estoque devolvido
-- 
-- STATUS FISCAL:
-- NULL ou ''           - Sem nota emitida
-- EMITIDA_NFCE        - NFC-e autorizada pela SEFAZ
-- ERRO_EMISSAO        - Erro ao emitir nota
-- =====================================================
