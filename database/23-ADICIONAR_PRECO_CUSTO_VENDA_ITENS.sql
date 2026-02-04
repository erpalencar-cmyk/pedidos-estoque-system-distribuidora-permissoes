-- =====================================================
-- Script para adicionar campo preco_custo em venda_itens
-- Para armazenar o custo histórico do produto na venda
-- =====================================================

-- Adicionar coluna preco_custo em venda_itens
DO $$
BEGIN
    -- Preço de custo real da compra
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'venda_itens' AND column_name = 'preco_custo') THEN
        ALTER TABLE venda_itens ADD COLUMN preco_custo DECIMAL(12,2);
        RAISE NOTICE 'Coluna preco_custo adicionada em venda_itens';
    END IF;
END $$;

-- Atualizar vendas existentes com o preco_custo do produto
UPDATE venda_itens vi
SET preco_custo = p.preco_custo
FROM produtos p
WHERE vi.produto_id = p.id
AND vi.preco_custo IS NULL;

-- Criar índice para melhor performance
CREATE INDEX IF NOT EXISTS idx_venda_itens_lote ON venda_itens(lote_id);

-- =====================================================
-- FUNÇÃO PARA BUSCAR PREÇO DE CUSTO NA VENDA
-- Lógica:
-- 1. Se tem lote_id, buscar preco_custo do produto_lotes
-- 2. Se não, buscar do último pedido de compra
-- 3. Se não, usar preco_custo do produtos
-- =====================================================

CREATE OR REPLACE FUNCTION get_preco_custo_para_venda(
    p_produto_id UUID,
    p_lote_id UUID DEFAULT NULL
) RETURNS DECIMAL(12,2) AS $$
DECLARE
    v_preco_custo DECIMAL(12,2);
BEGIN
    -- 1. Tentar buscar do lote específico
    IF p_lote_id IS NOT NULL THEN
        SELECT preco_custo INTO v_preco_custo
        FROM produto_lotes
        WHERE id = p_lote_id;
        
        IF v_preco_custo IS NOT NULL AND v_preco_custo > 0 THEN
            RETURN v_preco_custo;
        END IF;
    END IF;
    
    -- 2. Buscar do último pedido de compra recebido
    SELECT pci.preco_unitario INTO v_preco_custo
    FROM pedido_compra_itens pci
    JOIN pedidos_compra pc ON pci.pedido_id = pc.id
    WHERE pci.produto_id = p_produto_id
    AND pc.status = 'RECEBIDO'
    AND pci.quantidade_recebida > 0
    ORDER BY pc.data_recebimento DESC, pc.created_at DESC
    LIMIT 1;
    
    IF v_preco_custo IS NOT NULL AND v_preco_custo > 0 THEN
        RETURN v_preco_custo;
    END IF;
    
    -- 3. Fallback: usar preco_custo do cadastro do produto
    SELECT preco_custo INTO v_preco_custo
    FROM produtos
    WHERE id = p_produto_id;
    
    RETURN COALESCE(v_preco_custo, 0);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TRIGGER para preencher preco_custo automaticamente
-- =====================================================

CREATE OR REPLACE FUNCTION trg_venda_item_set_preco_custo()
RETURNS TRIGGER AS $$
BEGIN
    -- Se preco_custo não foi informado, buscar automaticamente
    IF NEW.preco_custo IS NULL OR NEW.preco_custo = 0 THEN
        NEW.preco_custo := get_preco_custo_para_venda(NEW.produto_id, NEW.lote_id);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_before_insert_venda_item_custo ON venda_itens;
CREATE TRIGGER trg_before_insert_venda_item_custo
    BEFORE INSERT ON venda_itens
    FOR EACH ROW
    EXECUTE FUNCTION trg_venda_item_set_preco_custo();

-- =====================================================
-- VERIFICAÇÃO
-- =====================================================

SELECT 
    '✅ Script executado com sucesso!' as status,
    'Campo preco_custo adicionado em venda_itens + Função e Trigger criados' as resumo;

-- Mostrar exemplo de uso da função
SELECT 
    'Exemplo de uso da função get_preco_custo_para_venda:' as info;

-- SELECT get_preco_custo_para_venda('id-do-produto'::uuid);
-- SELECT get_preco_custo_para_venda('id-do-produto'::uuid, 'id-do-lote'::uuid);
