-- Script para reconstruir a tabela caixa_sessoes com todas as colunas necessárias

-- Passo 1: Criar tabela se não existir
CREATE TABLE IF NOT EXISTS caixa_sessoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Passo 2: Adicionar colunas necessárias (de forma segura)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixa_sessoes' AND column_name = 'caixa_id') THEN
        ALTER TABLE caixa_sessoes ADD COLUMN caixa_id UUID NOT NULL;
        RAISE NOTICE 'Coluna caixa_id adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixa_sessoes' AND column_name = 'operador_id') THEN
        ALTER TABLE caixa_sessoes ADD COLUMN operador_id UUID NOT NULL;
        RAISE NOTICE 'Coluna operador_id adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixa_sessoes' AND column_name = 'data_abertura') THEN
        ALTER TABLE caixa_sessoes ADD COLUMN data_abertura TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Coluna data_abertura adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixa_sessoes' AND column_name = 'data_fechamento') THEN
        ALTER TABLE caixa_sessoes ADD COLUMN data_fechamento TIMESTAMP WITH TIME ZONE;
        RAISE NOTICE 'Coluna data_fechamento adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixa_sessoes' AND column_name = 'valor_abertura') THEN
        ALTER TABLE caixa_sessoes ADD COLUMN valor_abertura DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Coluna valor_abertura adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixa_sessoes' AND column_name = 'valor_fechamento') THEN
        ALTER TABLE caixa_sessoes ADD COLUMN valor_fechamento DECIMAL(12,2);
        RAISE NOTICE 'Coluna valor_fechamento adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixa_sessoes' AND column_name = 'valor_vendas') THEN
        ALTER TABLE caixa_sessoes ADD COLUMN valor_vendas DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Coluna valor_vendas adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixa_sessoes' AND column_name = 'valor_sangrias') THEN
        ALTER TABLE caixa_sessoes ADD COLUMN valor_sangrias DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Coluna valor_sangrias adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixa_sessoes' AND column_name = 'valor_suprimentos') THEN
        ALTER TABLE caixa_sessoes ADD COLUMN valor_suprimentos DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Coluna valor_suprimentos adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixa_sessoes' AND column_name = 'diferenca') THEN
        ALTER TABLE caixa_sessoes ADD COLUMN diferenca DECIMAL(12,2);
        RAISE NOTICE 'Coluna diferenca adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixa_sessoes' AND column_name = 'status') THEN
        ALTER TABLE caixa_sessoes ADD COLUMN status VARCHAR(20) DEFAULT 'ABERTO';
        RAISE NOTICE 'Coluna status adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixa_sessoes' AND column_name = 'observacoes') THEN
        ALTER TABLE caixa_sessoes ADD COLUMN observacoes TEXT;
        RAISE NOTICE 'Coluna observacoes adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixa_sessoes' AND column_name = 'updated_at') THEN
        ALTER TABLE caixa_sessoes ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Coluna updated_at adicionada';
    END IF;
END $$;

-- Passo 3: Garantir que as tabelas referenciadas existem e são válidas
CREATE TABLE IF NOT EXISTS caixas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Passo 4: Adicionar ou recriar foreign keys
-- Remover constraints antigas se existirem
ALTER TABLE caixa_sessoes DROP CONSTRAINT IF EXISTS fk_caixa_sessoes_caixa;
ALTER TABLE caixa_sessoes DROP CONSTRAINT IF EXISTS fk_caixa_sessoes_operador;

-- Adicionar constraint para caixa_id
ALTER TABLE caixa_sessoes 
ADD CONSTRAINT fk_caixa_sessoes_caixa 
FOREIGN KEY (caixa_id) REFERENCES caixas(id);

-- Adicionar constraint para operador_id
ALTER TABLE caixa_sessoes 
ADD CONSTRAINT fk_caixa_sessoes_operador 
FOREIGN KEY (operador_id) REFERENCES users(id);

-- Passo 5: Recriar índices
DROP INDEX IF EXISTS idx_sessoes_caixa;
DROP INDEX IF EXISTS idx_sessoes_operador;
DROP INDEX IF EXISTS idx_sessoes_status;
DROP INDEX IF EXISTS idx_caixa_sessoes_status;
DROP INDEX IF EXISTS idx_caixa_sessoes_usuario;
DROP INDEX IF EXISTS idx_caixa_sessoes_data;

CREATE INDEX idx_sessoes_caixa ON caixa_sessoes(caixa_id);
CREATE INDEX idx_sessoes_operador ON caixa_sessoes(operador_id);
CREATE INDEX idx_sessoes_status ON caixa_sessoes(status);
CREATE INDEX idx_caixa_sessoes_data ON caixa_sessoes(data_abertura DESC);

-- Verificação
SELECT 'Script concluído com sucesso!' as resultado;
