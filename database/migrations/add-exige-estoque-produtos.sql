-- Adicionar campo para controlar se produto exige validação de estoque
ALTER TABLE public.produtos
ADD COLUMN exige_estoque boolean DEFAULT true NOT NULL;

-- Índice para filtrar produtos que exigem estoque
CREATE INDEX idx_produtos_exige_estoque ON public.produtos USING btree (exige_estoque);

-- Adicionar comentário explicativo
COMMENT ON COLUMN public.produtos.exige_estoque IS 'Se false, o produto não exigirá validação de estoque no PDV nem em pedidos de venda. Útil para serviços, vouchers, etc.';
