-- Script para reconstruir/verificar tabela contas_receber com TODAS as colunas
-- Este script garante que todas as colunas necessárias existem

-- Passo 1: Criar tabela básica se não existir
CREATE TABLE IF NOT EXISTS contas_receber (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Passo 2: Adicionar colunas que faltam (de forma segura)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'numero_documento') THEN
        ALTER TABLE contas_receber ADD COLUMN numero_documento VARCHAR(50);
        RAISE NOTICE 'Coluna numero_documento adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'descricao') THEN
        ALTER TABLE contas_receber ADD COLUMN descricao VARCHAR(255);
        RAISE NOTICE 'Coluna descricao adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'cliente_id') THEN
        ALTER TABLE contas_receber ADD COLUMN cliente_id UUID;
        RAISE NOTICE 'Coluna cliente_id adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'venda_id') THEN
        ALTER TABLE contas_receber ADD COLUMN venda_id UUID;
        RAISE NOTICE 'Coluna venda_id adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'valor_original') THEN
        ALTER TABLE contas_receber ADD COLUMN valor_original DECIMAL(12,2) NOT NULL DEFAULT 0;
        RAISE NOTICE 'Coluna valor_original adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'valor_desconto') THEN
        ALTER TABLE contas_receber ADD COLUMN valor_desconto DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Coluna valor_desconto adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'valor_juros') THEN
        ALTER TABLE contas_receber ADD COLUMN valor_juros DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Coluna valor_juros adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'valor_multa') THEN
        ALTER TABLE contas_receber ADD COLUMN valor_multa DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Coluna valor_multa adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'valor_recebido') THEN
        ALTER TABLE contas_receber ADD COLUMN valor_recebido DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Coluna valor_recebido adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'data_emissao') THEN
        ALTER TABLE contas_receber ADD COLUMN data_emissao DATE DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Coluna data_emissao adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'data_vencimento') THEN
        ALTER TABLE contas_receber ADD COLUMN data_vencimento DATE;
        RAISE NOTICE 'Coluna data_vencimento adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'data_recebimento') THEN
        ALTER TABLE contas_receber ADD COLUMN data_recebimento DATE;
        RAISE NOTICE 'Coluna data_recebimento adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'forma_recebimento') THEN
        ALTER TABLE contas_receber ADD COLUMN forma_recebimento VARCHAR(30);
        RAISE NOTICE 'Coluna forma_recebimento adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'conta_bancaria') THEN
        ALTER TABLE contas_receber ADD COLUMN conta_bancaria VARCHAR(100);
        RAISE NOTICE 'Coluna conta_bancaria adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'status') THEN
        ALTER TABLE contas_receber ADD COLUMN status VARCHAR(20) DEFAULT 'PENDENTE';
        RAISE NOTICE 'Coluna status adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'categoria') THEN
        ALTER TABLE contas_receber ADD COLUMN categoria VARCHAR(50) DEFAULT 'VENDA';
        RAISE NOTICE 'Coluna categoria adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'parcela_atual') THEN
        ALTER TABLE contas_receber ADD COLUMN parcela_atual INTEGER DEFAULT 1;
        RAISE NOTICE 'Coluna parcela_atual adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'total_parcelas') THEN
        ALTER TABLE contas_receber ADD COLUMN total_parcelas INTEGER DEFAULT 1;
        RAISE NOTICE 'Coluna total_parcelas adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'observacoes') THEN
        ALTER TABLE contas_receber ADD COLUMN observacoes TEXT;
        RAISE NOTICE 'Coluna observacoes adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'usuario_id') THEN
        ALTER TABLE contas_receber ADD COLUMN usuario_id UUID;
        RAISE NOTICE 'Coluna usuario_id adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'updated_at') THEN
        ALTER TABLE contas_receber ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Coluna updated_at adicionada';
    END IF;
END $$;

-- Passo 3: Recriar índices
DROP INDEX IF EXISTS idx_contas_receber_cliente;
DROP INDEX IF EXISTS idx_contas_receber_vencimento;
DROP INDEX IF EXISTS idx_contas_receber_status;

CREATE INDEX IF NOT EXISTS idx_contas_receber_cliente ON contas_receber(cliente_id);
CREATE INDEX IF NOT EXISTS idx_contas_receber_vencimento ON contas_receber(data_vencimento);
CREATE INDEX IF NOT EXISTS idx_contas_receber_status ON contas_receber(status);

-- Passo 4: Verificar estrutura final
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'contas_receber'
ORDER BY ordinal_position;
