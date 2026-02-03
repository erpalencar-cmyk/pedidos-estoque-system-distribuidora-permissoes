-- Script para reconstruir/verificar tabela vendas
-- Este script garante que todas as colunas necessárias existem

-- Passo 1: Criar tabela básica se não existir (sem constraints complexas)
CREATE TABLE IF NOT EXISTS vendas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Passo 2: Adicionar colunas que faltam (de forma segura)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendas' 
        AND column_name = 'numero'
    ) THEN
        ALTER TABLE vendas ADD COLUMN numero VARCHAR(20);
        RAISE NOTICE 'Coluna numero adicionada em vendas';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendas' 
        AND column_name = 'status'
    ) THEN
        ALTER TABLE vendas ADD COLUMN status VARCHAR(20) DEFAULT 'FINALIZADA';
        RAISE NOTICE 'Coluna status adicionada em vendas';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendas' 
        AND column_name = 'data_venda'
    ) THEN
        ALTER TABLE vendas ADD COLUMN data_venda TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Coluna data_venda adicionada em vendas';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendas' 
        AND column_name = 'total'
    ) THEN
        ALTER TABLE vendas ADD COLUMN total DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Coluna total adicionada em vendas';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendas' 
        AND column_name = 'forma_pagamento'
    ) THEN
        ALTER TABLE vendas ADD COLUMN forma_pagamento VARCHAR(30);
        RAISE NOTICE 'Coluna forma_pagamento adicionada em vendas';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendas' 
        AND column_name = 'sessao_id'
    ) THEN
        ALTER TABLE vendas ADD COLUMN sessao_id UUID;
        RAISE NOTICE 'Coluna sessao_id adicionada em vendas';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendas' 
        AND column_name = 'cliente_id'
    ) THEN
        ALTER TABLE vendas ADD COLUMN cliente_id UUID;
        RAISE NOTICE 'Coluna cliente_id adicionada em vendas';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendas' 
        AND column_name = 'vendedor_id'
    ) THEN
        ALTER TABLE vendas ADD COLUMN vendedor_id UUID;
        RAISE NOTICE 'Coluna vendedor_id adicionada em vendas';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendas' 
        AND column_name = 'subtotal'
    ) THEN
        ALTER TABLE vendas ADD COLUMN subtotal DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Coluna subtotal adicionada em vendas';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendas' 
        AND column_name = 'desconto_valor'
    ) THEN
        ALTER TABLE vendas ADD COLUMN desconto_valor DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Coluna desconto_valor adicionada em vendas';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendas' 
        AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE vendas ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Coluna updated_at adicionada em vendas';
    END IF;
END $$;

-- Passo 3: Recriar índices (com segurança)
DROP INDEX IF EXISTS idx_vendas_numero;
DROP INDEX IF EXISTS idx_vendas_sessao;
DROP INDEX IF EXISTS idx_vendas_cliente;
DROP INDEX IF EXISTS idx_vendas_data;

CREATE INDEX IF NOT EXISTS idx_vendas_numero ON vendas(numero);
CREATE INDEX IF NOT EXISTS idx_vendas_sessao ON vendas(sessao_id);
CREATE INDEX IF NOT EXISTS idx_vendas_cliente ON vendas(cliente_id);
CREATE INDEX IF NOT EXISTS idx_vendas_data ON vendas(data_venda);

-- Passo 4: Verificar estrutura final
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'vendas'
ORDER BY ordinal_position;
