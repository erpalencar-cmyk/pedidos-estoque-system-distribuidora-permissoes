-- Script para adicionar colunas faltantes na tabela users
-- Adiciona full_name e outras colunas necessárias

DO $$
BEGIN
    -- Adicionar full_name
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'full_name') THEN
        ALTER TABLE users ADD COLUMN full_name VARCHAR(255);
        RAISE NOTICE 'Coluna full_name adicionada';
    END IF;

    -- Adicionar role
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'role') THEN
        ALTER TABLE users ADD COLUMN role VARCHAR(50) DEFAULT 'VENDEDOR';
        RAISE NOTICE 'Coluna role adicionada';
    END IF;

    -- Adicionar approved
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'approved') THEN
        ALTER TABLE users ADD COLUMN approved BOOLEAN DEFAULT false;
        RAISE NOTICE 'Coluna approved adicionada';
    END IF;

    -- Adicionar approved_by
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'approved_by') THEN
        ALTER TABLE users ADD COLUMN approved_by UUID;
        RAISE NOTICE 'Coluna approved_by adicionada';
    END IF;

    -- Adicionar approved_at
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'approved_at') THEN
        ALTER TABLE users ADD COLUMN approved_at TIMESTAMP WITH TIME ZONE;
        RAISE NOTICE 'Coluna approved_at adicionada';
    END IF;

    -- Adicionar telefone
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'telefone') THEN
        ALTER TABLE users ADD COLUMN telefone VARCHAR(20);
        RAISE NOTICE 'Coluna telefone adicionada';
    END IF;

    -- Adicionar cpf
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'cpf') THEN
        ALTER TABLE users ADD COLUMN cpf VARCHAR(14);
        RAISE NOTICE 'Coluna cpf adicionada';
    END IF;

    -- Adicionar email se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'email') THEN
        ALTER TABLE users ADD COLUMN email VARCHAR(255);
        RAISE NOTICE 'Coluna email adicionada';
    END IF;

    -- Adicionar ativo (se ainda não foi adicionado pelo script anterior)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'ativo') THEN
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'active') THEN
            ALTER TABLE users RENAME COLUMN active TO ativo;
            RAISE NOTICE 'Coluna active renomeada para ativo';
        ELSE
            ALTER TABLE users ADD COLUMN ativo BOOLEAN DEFAULT true;
            RAISE NOTICE 'Coluna ativo criada';
        END IF;
    END IF;

    -- Adicionar updated_at
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'updated_at') THEN
        ALTER TABLE users ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Coluna updated_at adicionada';
    END IF;

END $$;

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_ativo ON users(ativo);

-- Verificação final
SELECT 'Script concluído com sucesso!' as resultado;
