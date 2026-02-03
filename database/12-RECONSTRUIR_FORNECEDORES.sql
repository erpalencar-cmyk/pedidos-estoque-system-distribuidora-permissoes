-- Script para reconstruir/verificar tabela fornecedores com TODAS as colunas
-- Este script garante que todas as colunas necessárias existem

-- Passo 1: Criar tabela básica se não existir
CREATE TABLE IF NOT EXISTS fornecedores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Passo 2: Adicionar colunas que faltam (de forma segura)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fornecedores' AND column_name = 'razao_social') THEN
        ALTER TABLE fornecedores ADD COLUMN razao_social VARCHAR(150) NOT NULL;
        RAISE NOTICE 'Coluna razao_social adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fornecedores' AND column_name = 'nome_fantasia') THEN
        ALTER TABLE fornecedores ADD COLUMN nome_fantasia VARCHAR(150);
        RAISE NOTICE 'Coluna nome_fantasia adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fornecedores' AND column_name = 'cnpj') THEN
        ALTER TABLE fornecedores ADD COLUMN cnpj VARCHAR(20) UNIQUE;
        RAISE NOTICE 'Coluna cnpj adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fornecedores' AND column_name = 'inscricao_estadual') THEN
        ALTER TABLE fornecedores ADD COLUMN inscricao_estadual VARCHAR(20);
        RAISE NOTICE 'Coluna inscricao_estadual adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fornecedores' AND column_name = 'telefone') THEN
        ALTER TABLE fornecedores ADD COLUMN telefone VARCHAR(20);
        RAISE NOTICE 'Coluna telefone adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fornecedores' AND column_name = 'email') THEN
        ALTER TABLE fornecedores ADD COLUMN email VARCHAR(100);
        RAISE NOTICE 'Coluna email adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fornecedores' AND column_name = 'endereco') THEN
        ALTER TABLE fornecedores ADD COLUMN endereco VARCHAR(200);
        RAISE NOTICE 'Coluna endereco adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fornecedores' AND column_name = 'numero') THEN
        ALTER TABLE fornecedores ADD COLUMN numero VARCHAR(20);
        RAISE NOTICE 'Coluna numero adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fornecedores' AND column_name = 'complemento') THEN
        ALTER TABLE fornecedores ADD COLUMN complemento VARCHAR(100);
        RAISE NOTICE 'Coluna complemento adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fornecedores' AND column_name = 'bairro') THEN
        ALTER TABLE fornecedores ADD COLUMN bairro VARCHAR(100);
        RAISE NOTICE 'Coluna bairro adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fornecedores' AND column_name = 'cidade') THEN
        ALTER TABLE fornecedores ADD COLUMN cidade VARCHAR(100);
        RAISE NOTICE 'Coluna cidade adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fornecedores' AND column_name = 'estado') THEN
        ALTER TABLE fornecedores ADD COLUMN estado VARCHAR(2);
        RAISE NOTICE 'Coluna estado adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fornecedores' AND column_name = 'cep') THEN
        ALTER TABLE fornecedores ADD COLUMN cep VARCHAR(10);
        RAISE NOTICE 'Coluna cep adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fornecedores' AND column_name = 'ativo') THEN
        ALTER TABLE fornecedores ADD COLUMN ativo BOOLEAN DEFAULT true;
        RAISE NOTICE 'Coluna ativo adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fornecedores' AND column_name = 'usuario_id') THEN
        ALTER TABLE fornecedores ADD COLUMN usuario_id UUID;
        RAISE NOTICE 'Coluna usuario_id adicionada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fornecedores' AND column_name = 'updated_at') THEN
        ALTER TABLE fornecedores ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Coluna updated_at adicionada';
    END IF;
END $$;

-- Passo 3: Recriar índices
DROP INDEX IF EXISTS idx_fornecedores_razao_social;
DROP INDEX IF EXISTS idx_fornecedores_cnpj;
DROP INDEX IF EXISTS idx_fornecedores_ativo;

CREATE INDEX IF NOT EXISTS idx_fornecedores_razao_social ON fornecedores(razao_social);
CREATE INDEX IF NOT EXISTS idx_fornecedores_cnpj ON fornecedores(cnpj);
CREATE INDEX IF NOT EXISTS idx_fornecedores_ativo ON fornecedores(ativo);

-- Passo 4: Verificar estrutura final
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'fornecedores'
ORDER BY ordinal_position;
