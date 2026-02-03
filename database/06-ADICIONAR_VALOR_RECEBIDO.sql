-- Script para reconstruir/verificar tabela contas_receber
-- Este script garante que todas as colunas necessárias existem

-- Passo 1: Se a tabela não existe, criar
CREATE TABLE IF NOT EXISTS contas_receber (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    numero_documento VARCHAR(50),
    descricao VARCHAR(255) NOT NULL,
    cliente_id UUID REFERENCES clientes(id),
    venda_id UUID REFERENCES vendas(id),
    
    -- Valores
    valor_original DECIMAL(12,2) NOT NULL,
    valor_desconto DECIMAL(12,2) DEFAULT 0,
    valor_juros DECIMAL(12,2) DEFAULT 0,
    valor_multa DECIMAL(12,2) DEFAULT 0,
    valor_recebido DECIMAL(12,2) DEFAULT 0,
    valor_total DECIMAL(12,2) GENERATED ALWAYS AS (
        valor_original - valor_desconto + valor_juros + valor_multa
    ) STORED,
    
    -- Datas
    data_emissao DATE DEFAULT CURRENT_DATE,
    data_vencimento DATE NOT NULL,
    data_recebimento DATE,
    
    -- Forma de recebimento
    forma_recebimento VARCHAR(30),
    conta_bancaria VARCHAR(100),
    
    -- Status
    status VARCHAR(20) DEFAULT 'PENDENTE' CHECK (status IN ('PENDENTE', 'RECEBIDO', 'RECEBIDO_PARCIAL', 'VENCIDO', 'CANCELADO')),
    
    -- Categorização
    categoria VARCHAR(50) DEFAULT 'VENDA',
    
    -- Parcelas
    parcela_atual INTEGER DEFAULT 1,
    total_parcelas INTEGER DEFAULT 1,
    
    observacoes TEXT,
    usuario_id UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Passo 2: Adicionar colunas que faltam
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'contas_receber' 
        AND column_name = 'valor_recebido'
    ) THEN
        ALTER TABLE contas_receber ADD COLUMN valor_recebido DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Coluna valor_recebido adicionada';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'contas_receber' 
        AND column_name = 'status'
    ) THEN
        ALTER TABLE contas_receber ADD COLUMN status VARCHAR(20) DEFAULT 'PENDENTE';
        RAISE NOTICE 'Coluna status adicionada';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'contas_receber' 
        AND column_name = 'valor_desconto'
    ) THEN
        ALTER TABLE contas_receber ADD COLUMN valor_desconto DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Coluna valor_desconto adicionada';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'contas_receber' 
        AND column_name = 'valor_juros'
    ) THEN
        ALTER TABLE contas_receber ADD COLUMN valor_juros DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Coluna valor_juros adicionada';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'contas_receber' 
        AND column_name = 'valor_multa'
    ) THEN
        ALTER TABLE contas_receber ADD COLUMN valor_multa DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Coluna valor_multa adicionada';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'contas_receber' 
        AND column_name = 'data_recebimento'
    ) THEN
        ALTER TABLE contas_receber ADD COLUMN data_recebimento DATE;
        RAISE NOTICE 'Coluna data_recebimento adicionada';
    END IF;
END $$;

-- Passo 3: Recriar índices
DROP INDEX IF EXISTS idx_contas_receber_cliente;
DROP INDEX IF EXISTS idx_contas_receber_vencimento;
DROP INDEX IF EXISTS idx_contas_receber_status;

CREATE INDEX idx_contas_receber_cliente ON contas_receber(cliente_id);
CREATE INDEX idx_contas_receber_vencimento ON contas_receber(data_vencimento);
CREATE INDEX idx_contas_receber_status ON contas_receber(status);

-- Passo 4: Verificar estrutura final
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'contas_receber'
ORDER BY ordinal_position;
