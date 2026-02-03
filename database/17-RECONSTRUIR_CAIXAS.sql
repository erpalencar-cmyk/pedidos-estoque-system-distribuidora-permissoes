-- Script para reconstruir a tabela caixas com todas as colunas necessárias

-- Passo 1: Criar tabela se não existir
CREATE TABLE IF NOT EXISTS caixas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Passo 2: Adicionar colunas necessárias (de forma segura)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixas' AND column_name = 'numero') THEN
        ALTER TABLE caixas ADD COLUMN numero INTEGER UNIQUE;
        RAISE NOTICE 'Coluna numero adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixas' AND column_name = 'nome') THEN
        ALTER TABLE caixas ADD COLUMN nome VARCHAR(100);
        RAISE NOTICE 'Coluna nome adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixas' AND column_name = 'impressora_nfce') THEN
        ALTER TABLE caixas ADD COLUMN impressora_nfce VARCHAR(100);
        RAISE NOTICE 'Coluna impressora_nfce adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixas' AND column_name = 'impressora_cupom') THEN
        ALTER TABLE caixas ADD COLUMN impressora_cupom VARCHAR(100);
        RAISE NOTICE 'Coluna impressora_cupom adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixas' AND column_name = 'terminal') THEN
        ALTER TABLE caixas ADD COLUMN terminal VARCHAR(100);
        RAISE NOTICE 'Coluna terminal adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixas' AND column_name = 'ativo') THEN
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixas' AND column_name = 'active') THEN
            ALTER TABLE caixas RENAME COLUMN active TO ativo;
            RAISE NOTICE 'Coluna active renomeada para ativo';
        ELSE
            ALTER TABLE caixas ADD COLUMN ativo BOOLEAN DEFAULT true;
            RAISE NOTICE 'Coluna ativo criada';
        END IF;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixas' AND column_name = 'updated_at') THEN
        ALTER TABLE caixas ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Coluna updated_at adicionada';
    END IF;
END $$;

-- Passo 3: Recriar índices
DROP INDEX IF EXISTS idx_caixas_numero;
DROP INDEX IF EXISTS idx_caixas_ativo;

CREATE INDEX IF NOT EXISTS idx_caixas_numero ON caixas(numero);
CREATE INDEX IF NOT EXISTS idx_caixas_ativo ON caixas(ativo);

-- Passo 4: Adicionar constraint UNIQUE em numero se não existir
ALTER TABLE caixas DROP CONSTRAINT IF EXISTS caixas_numero_key;
ALTER TABLE caixas ADD CONSTRAINT caixas_numero_key UNIQUE (numero);

-- Passo 5: Inserir dados padrão se tabela estiver vazia
INSERT INTO caixas (numero, nome, ativo) 
VALUES (1, 'Caixa Principal', true)
ON CONFLICT (numero) DO NOTHING;

-- Verificação final
SELECT 'Script concluído com sucesso!' as resultado;
SELECT COUNT(*) as total_caixas FROM caixas;
