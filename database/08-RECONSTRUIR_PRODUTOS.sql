-- Script para reconstruir/verificar tabela produtos
-- Este script garante que todas as colunas necessárias existem

-- Passo 1: Criar tabela básica se não existir
CREATE TABLE IF NOT EXISTS produtos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Passo 2: Adicionar colunas que faltam (de forma segura)
DO $$
BEGIN
    -- Colunas básicas
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'codigo') THEN
        ALTER TABLE produtos ADD COLUMN codigo VARCHAR(50);
        RAISE NOTICE 'Coluna codigo adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'sku') THEN
        ALTER TABLE produtos ADD COLUMN sku VARCHAR(50);
        RAISE NOTICE 'Coluna sku adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'codigo_barras') THEN
        ALTER TABLE produtos ADD COLUMN codigo_barras VARCHAR(50);
        RAISE NOTICE 'Coluna codigo_barras adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'nome') THEN
        ALTER TABLE produtos ADD COLUMN nome VARCHAR(255) NOT NULL DEFAULT '';
        RAISE NOTICE 'Coluna nome adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'descricao') THEN
        ALTER TABLE produtos ADD COLUMN descricao TEXT;
        RAISE NOTICE 'Coluna descricao adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'marca') THEN
        ALTER TABLE produtos ADD COLUMN marca VARCHAR(100);
        RAISE NOTICE 'Coluna marca adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'categoria_id') THEN
        ALTER TABLE produtos ADD COLUMN categoria_id UUID;
        RAISE NOTICE 'Coluna categoria_id adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'unidade') THEN
        ALTER TABLE produtos ADD COLUMN unidade VARCHAR(20) DEFAULT 'UN';
        RAISE NOTICE 'Coluna unidade adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'preco_custo') THEN
        ALTER TABLE produtos ADD COLUMN preco_custo DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Coluna preco_custo adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'preco_venda') THEN
        ALTER TABLE produtos ADD COLUMN preco_venda DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Coluna preco_venda adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'estoque_atual') THEN
        ALTER TABLE produtos ADD COLUMN estoque_atual DECIMAL(12,3) DEFAULT 0;
        RAISE NOTICE 'Coluna estoque_atual adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'estoque_minimo') THEN
        ALTER TABLE produtos ADD COLUMN estoque_minimo DECIMAL(12,3) DEFAULT 0;
        RAISE NOTICE 'Coluna estoque_minimo adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'estoque_maximo') THEN
        ALTER TABLE produtos ADD COLUMN estoque_maximo DECIMAL(12,3) DEFAULT 0;
        RAISE NOTICE 'Coluna estoque_maximo adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'ativo') THEN
        ALTER TABLE produtos ADD COLUMN ativo BOOLEAN DEFAULT true;
        RAISE NOTICE 'Coluna ativo adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'updated_at') THEN
        ALTER TABLE produtos ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Coluna updated_at adicionada';
    END IF;

    -- Colunas fiscais
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'ncm') THEN
        ALTER TABLE produtos ADD COLUMN ncm VARCHAR(10);
        RAISE NOTICE 'Coluna ncm adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'cfop') THEN
        ALTER TABLE produtos ADD COLUMN cfop VARCHAR(10);
        RAISE NOTICE 'Coluna cfop adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'aliquota_icms') THEN
        ALTER TABLE produtos ADD COLUMN aliquota_icms DECIMAL(5,2) DEFAULT 0;
        RAISE NOTICE 'Coluna aliquota_icms adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'aliquota_pis') THEN
        ALTER TABLE produtos ADD COLUMN aliquota_pis DECIMAL(5,4) DEFAULT 0;
        RAISE NOTICE 'Coluna aliquota_pis adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'aliquota_cofins') THEN
        ALTER TABLE produtos ADD COLUMN aliquota_cofins DECIMAL(5,4) DEFAULT 0;
        RAISE NOTICE 'Coluna aliquota_cofins adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'aliquota_ipi') THEN
        ALTER TABLE produtos ADD COLUMN aliquota_ipi DECIMAL(5,2) DEFAULT 0;
        RAISE NOTICE 'Coluna aliquota_ipi adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'fornecedor_id') THEN
        ALTER TABLE produtos ADD COLUMN fornecedor_id UUID;
        RAISE NOTICE 'Coluna fornecedor_id adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'imagem_url') THEN
        ALTER TABLE produtos ADD COLUMN imagem_url TEXT;
        RAISE NOTICE 'Coluna imagem_url adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'volume_ml') THEN
        ALTER TABLE produtos ADD COLUMN volume_ml INTEGER;
        RAISE NOTICE 'Coluna volume_ml adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'controla_validade') THEN
        ALTER TABLE produtos ADD COLUMN controla_validade BOOLEAN DEFAULT true;
        RAISE NOTICE 'Coluna controla_validade adicionada';
    END IF;

END $$;

-- Passo 3: Recriar índices
DROP INDEX IF EXISTS idx_produtos_codigo;
DROP INDEX IF EXISTS idx_produtos_codigo_barras;
DROP INDEX IF EXISTS idx_produtos_marca;
DROP INDEX IF EXISTS idx_produtos_categoria;
DROP INDEX IF EXISTS idx_produtos_fornecedor;

CREATE INDEX IF NOT EXISTS idx_produtos_codigo ON produtos(codigo);
CREATE INDEX IF NOT EXISTS idx_produtos_codigo_barras ON produtos(codigo_barras);
CREATE INDEX IF NOT EXISTS idx_produtos_marca ON produtos(marca);
CREATE INDEX IF NOT EXISTS idx_produtos_categoria ON produtos(categoria_id);
CREATE INDEX IF NOT EXISTS idx_produtos_fornecedor ON produtos(fornecedor_id);

-- Passo 4: Verificar estrutura final
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'produtos'
ORDER BY ordinal_position;
