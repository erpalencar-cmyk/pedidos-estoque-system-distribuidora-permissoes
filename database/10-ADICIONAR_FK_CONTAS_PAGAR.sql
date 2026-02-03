-- Script para adicionar foreign key relationship entre contas_pagar e fornecedores
-- Este script garante que a relação entre as tabelas está configurada corretamente

-- Passo 1: Verificar se a coluna fornecedor_id existe em contas_pagar
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'contas_pagar' 
        AND column_name = 'fornecedor_id'
    ) THEN
        ALTER TABLE contas_pagar ADD COLUMN fornecedor_id UUID;
        RAISE NOTICE 'Coluna fornecedor_id adicionada em contas_pagar';
    ELSE
        RAISE NOTICE 'Coluna fornecedor_id já existe em contas_pagar';
    END IF;
END $$;

-- Passo 2: Remover constraint existente se houver (para evitar conflito)
DO $$
BEGIN
    -- Tentar remover a constraint existente
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'contas_pagar' 
        AND constraint_name LIKE '%fornecedor%'
    ) THEN
        ALTER TABLE contas_pagar DROP CONSTRAINT IF EXISTS contas_pagar_fornecedor_id_fkey CASCADE;
        RAISE NOTICE 'Constraint anterior removida';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Nenhuma constraint anterior encontrada';
END $$;

-- Passo 3: Adicionar a foreign key constraint
DO $$
BEGIN
    ALTER TABLE contas_pagar 
    ADD CONSTRAINT contas_pagar_fornecedor_id_fkey 
    FOREIGN KEY (fornecedor_id) REFERENCES fornecedores(id);
    
    RAISE NOTICE 'Foreign key constraint adicionada entre contas_pagar e fornecedores';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Foreign key constraint já existe ou erro ao adicionar: %', SQLERRM;
END $$;

-- Passo 4: Criar índice para performance
CREATE INDEX IF NOT EXISTS idx_contas_pagar_fornecedor ON contas_pagar(fornecedor_id);

-- Passo 5: Verificar a estrutura
SELECT 
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS referenced_table_name,
    ccu.column_name AS referenced_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'contas_pagar' AND tc.constraint_type = 'FOREIGN KEY';
