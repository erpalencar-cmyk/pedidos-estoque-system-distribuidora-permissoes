-- Script para corrigir coluna 'active' -> 'ativo' em todas as tabelas
-- Este script reanomeia ou adiciona 'ativo' onde necessário

-- ============== CLIENTES ==============
DO $$
BEGIN
    -- Se a coluna 'active' existe em clientes, renomeá-la para 'ativo'
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'clientes' AND column_name = 'active') THEN
        ALTER TABLE clientes RENAME COLUMN active TO ativo;
        RAISE NOTICE 'Coluna clientes.active renomeada para ativo';
    END IF;
    
    -- Se 'ativo' não existe, criar
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'clientes' AND column_name = 'ativo') THEN
        ALTER TABLE clientes ADD COLUMN ativo BOOLEAN DEFAULT true;
        RAISE NOTICE 'Coluna clientes.ativo criada';
    END IF;
END $$;

-- ============== FORNECEDORES ==============
DO $$
BEGIN
    -- Se a coluna 'active' existe em fornecedores, renomeá-la para 'ativo'
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fornecedores' AND column_name = 'active') THEN
        ALTER TABLE fornecedores RENAME COLUMN active TO ativo;
        RAISE NOTICE 'Coluna fornecedores.active renomeada para ativo';
    END IF;
    
    -- Se 'ativo' não existe, criar
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fornecedores' AND column_name = 'ativo') THEN
        ALTER TABLE fornecedores ADD COLUMN ativo BOOLEAN DEFAULT true;
        RAISE NOTICE 'Coluna fornecedores.ativo criada';
    END IF;
END $$;

-- ============== USUARIOS/USERS ==============
DO $$
BEGIN
    -- Se a coluna 'active' existe em users, renomeá-la para 'ativo'
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'active') THEN
        ALTER TABLE users RENAME COLUMN active TO ativo;
        RAISE NOTICE 'Coluna users.active renomeada para ativo';
    END IF;
    
    -- Se 'ativo' não existe, criar
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'ativo') THEN
        ALTER TABLE users ADD COLUMN ativo BOOLEAN DEFAULT true;
        RAISE NOTICE 'Coluna users.ativo criada';
    END IF;
END $$;

-- ============== CAIXAS ==============
DO $$
BEGIN
    -- Se a coluna 'active' existe em caixas, renomeá-la para 'ativo'
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixas' AND column_name = 'active') THEN
        ALTER TABLE caixas RENAME COLUMN active TO ativo;
        RAISE NOTICE 'Coluna caixas.active renomeada para ativo';
    END IF;
    
    -- Se 'ativo' não existe, criar
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixas' AND column_name = 'ativo') THEN
        ALTER TABLE caixas ADD COLUMN ativo BOOLEAN DEFAULT true;
        RAISE NOTICE 'Coluna caixas.ativo criada';
    END IF;
END $$;

-- ============== RECRIAR ÍNDICES ==============
-- Remover índices antigos
DROP INDEX IF EXISTS idx_clientes_active;
DROP INDEX IF EXISTS idx_fornecedores_active;
DROP INDEX IF EXISTS idx_users_active;
DROP INDEX IF EXISTS idx_produtos_active;

-- Criar novos índices com o nome correto
CREATE INDEX IF NOT EXISTS idx_clientes_ativo ON clientes(ativo);
CREATE INDEX IF NOT EXISTS idx_fornecedores_ativo ON fornecedores(ativo);
CREATE INDEX IF NOT EXISTS idx_users_ativo ON users(ativo);
CREATE INDEX IF NOT EXISTS idx_produtos_ativo ON produtos(ativo);

-- Verificação final
SELECT 'Script concluído com sucesso!' as resultado;
SELECT COUNT(*) as total_colunas_ativo 
FROM information_schema.columns 
WHERE column_name = 'ativo' 
  AND table_name IN ('clientes', 'fornecedores', 'users', 'caixas', 'produtos');
