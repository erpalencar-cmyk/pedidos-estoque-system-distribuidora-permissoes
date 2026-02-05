-- =====================================================
-- SCRIPT DE LIMPEZA COMPLETA DO SISTEMA
-- =====================================================
-- 
-- ATENÇÃO: Este script irá:
-- 1. Limpar TODAS as vendas e itens de venda
-- 2. Limpar TODOS os pedidos de compra e itens
-- 3. Limpar TODAS as movimentações de estoque
-- 4. Zerar o estoque_atual de TODOS os produtos
-- 5. Limpar lotes de produtos (opcional)
-- 6. Manter todos os cadastros (produtos, clientes, fornecedores, usuários, etc.)
--
-- IMPORTANTE: Execute este script APENAS quando precisar resetar todo o sistema!
-- Não há como desfazer esta operação!
-- 
-- BACKUP: Antes de executar, faça backup do banco de dados!
-- =====================================================

DO $$ 
BEGIN
    -- ========== PASSO 1: VENDAS ==========
    RAISE NOTICE '🔄 Limpando vendas...';
    
    -- 1.1. Deletar itens de venda (ambas as tabelas)
    DELETE FROM vendas_itens;
    DELETE FROM venda_itens;
    
    -- 1.2. Deletar vendas
    DELETE FROM vendas;
    
    RAISE NOTICE '✅ Vendas limpas!';
    
    -- ========== PASSO 2: PEDIDOS DE COMPRA ==========
    RAISE NOTICE '🔄 Limpando pedidos de compra...';
    
    -- 2.1. Deletar itens de pedidos de compra
    DELETE FROM pedido_compra_itens;
    
    -- 2.2. Deletar pedidos de compra
    DELETE FROM pedidos_compra;
    
    RAISE NOTICE '✅ Pedidos de compra limpos!';
    
    -- ========== PASSO 3: MOVIMENTAÇÕES DE ESTOQUE ==========
    RAISE NOTICE '🔄 Limpando movimentações de estoque...';
    
    -- 3.1. Deletar TODAS as movimentações de estoque
    DELETE FROM estoque_movimentacoes;
    
    RAISE NOTICE '✅ Movimentações de estoque limpas!';
    
    -- ========== PASSO 4: ZERAR ESTOQUE DOS PRODUTOS ==========
    RAISE NOTICE '🔄 Zerando estoque dos produtos...';
    
    -- 4.1. Zerar o estoque_atual de TODOS os produtos
    UPDATE produtos 
    SET estoque_atual = 0,
        updated_at = NOW();
    
    RAISE NOTICE '✅ Estoque zerado!';
    
    -- ========== PASSO 5: LOTES (OPCIONAL) ==========
    -- Descomente as linhas abaixo se quiser também limpar os lotes
    
    -- RAISE NOTICE '🔄 Limpando lotes...';
    -- DELETE FROM produto_lotes;
    -- RAISE NOTICE '✅ Lotes limpos!';
    
    RAISE NOTICE '';
    RAISE NOTICE '====================================';
    RAISE NOTICE '✅ LIMPEZA CONCLUÍDA COM SUCESSO!';
    RAISE NOTICE '====================================';
    
END $$;

-- =====================================================
-- VERIFICAÇÃO: Contar registros após limpeza
-- =====================================================
SELECT 
    'Vendas restantes' as tabela,
    COUNT(*) as total
FROM vendas

UNION ALL

SELECT 
    'Itens de venda restantes' as tabela,
    COUNT(*) as total
FROM vendas_itens

UNION ALL

SELECT 
    'Pedidos de compra restantes' as tabela,
    COUNT(*) as total
FROM pedidos_compra

UNION ALL

SELECT 
    'Itens de pedidos restantes' as tabela,
    COUNT(*) as total
FROM pedido_compra_itens

UNION ALL

SELECT 
    'Movimentações de estoque restantes' as tabela,
    COUNT(*) as total
FROM estoque_movimentacoes

UNION ALL

SELECT 
    'Produtos com estoque > 0' as tabela,
    COUNT(*) as total
FROM produtos
WHERE estoque_atual > 0;

-- =====================================================
-- RESULTADO ESPERADO:
-- Todas as contagens devem retornar 0 (zero)
-- =====================================================
-- 
-- 📝 Próximos passos:
-- 1. Importar XMLs de NF-e (se tiver)
-- 2. Criar novos pedidos de compra
-- 3. Aprovar pedidos para gerar entrada de estoque
-- 4. Sistema recalculará estoque automaticamente
-- =====================================================
