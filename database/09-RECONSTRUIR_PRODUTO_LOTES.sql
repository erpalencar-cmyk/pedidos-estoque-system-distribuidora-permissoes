-- Script para reconstruir/verificar tabela produto_lotes
-- Este script garante que todas as colunas necessárias existem

-- Passo 1: Criar tabela básica se não existir
CREATE TABLE IF NOT EXISTS produto_lotes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Passo 2: Adicionar colunas que faltam (de forma segura)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produto_lotes' AND column_name = 'produto_id') THEN
        ALTER TABLE produto_lotes ADD COLUMN produto_id UUID;
        RAISE NOTICE 'Coluna produto_id adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produto_lotes' AND column_name = 'numero_lote') THEN
        ALTER TABLE produto_lotes ADD COLUMN numero_lote VARCHAR(50);
        RAISE NOTICE 'Coluna numero_lote adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produto_lotes' AND column_name = 'data_fabricacao') THEN
        ALTER TABLE produto_lotes ADD COLUMN data_fabricacao DATE;
        RAISE NOTICE 'Coluna data_fabricacao adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produto_lotes' AND column_name = 'data_validade') THEN
        ALTER TABLE produto_lotes ADD COLUMN data_validade DATE;
        RAISE NOTICE 'Coluna data_validade adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produto_lotes' AND column_name = 'quantidade_inicial') THEN
        ALTER TABLE produto_lotes ADD COLUMN quantidade_inicial DECIMAL(12,3) DEFAULT 0;
        RAISE NOTICE 'Coluna quantidade_inicial adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produto_lotes' AND column_name = 'quantidade_atual') THEN
        ALTER TABLE produto_lotes ADD COLUMN quantidade_atual DECIMAL(12,3) DEFAULT 0;
        RAISE NOTICE 'Coluna quantidade_atual adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produto_lotes' AND column_name = 'preco_custo') THEN
        ALTER TABLE produto_lotes ADD COLUMN preco_custo DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Coluna preco_custo adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produto_lotes' AND column_name = 'fornecedor_id') THEN
        ALTER TABLE produto_lotes ADD COLUMN fornecedor_id UUID;
        RAISE NOTICE 'Coluna fornecedor_id adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produto_lotes' AND column_name = 'nota_fiscal') THEN
        ALTER TABLE produto_lotes ADD COLUMN nota_fiscal VARCHAR(50);
        RAISE NOTICE 'Coluna nota_fiscal adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produto_lotes' AND column_name = 'observacoes') THEN
        ALTER TABLE produto_lotes ADD COLUMN observacoes TEXT;
        RAISE NOTICE 'Coluna observacoes adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produto_lotes' AND column_name = 'status') THEN
        ALTER TABLE produto_lotes ADD COLUMN status VARCHAR(20) DEFAULT 'ATIVO';
        RAISE NOTICE 'Coluna status adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produto_lotes' AND column_name = 'updated_at') THEN
        ALTER TABLE produto_lotes ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Coluna updated_at adicionada';
    END IF;
END $$;

-- Passo 3: Recriar índices
DROP INDEX IF EXISTS idx_lotes_produto;
DROP INDEX IF EXISTS idx_lotes_validade;
DROP INDEX IF EXISTS idx_lotes_status;

CREATE INDEX IF NOT EXISTS idx_lotes_produto ON produto_lotes(produto_id);
CREATE INDEX IF NOT EXISTS idx_lotes_validade ON produto_lotes(data_validade);
CREATE INDEX IF NOT EXISTS idx_lotes_status ON produto_lotes(status);

-- Passo 4: Verificar estrutura final
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'produto_lotes'
ORDER BY ordinal_position;
