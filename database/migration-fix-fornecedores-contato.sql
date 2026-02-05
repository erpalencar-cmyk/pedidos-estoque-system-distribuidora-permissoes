-- =====================================================
-- MIGRATION: Corrigir campo 'contato' para 'contato_telefone' em fornecedores
-- =====================================================
-- Objetivo: Ajustar schema caso tenha campo 'contato' em vez de 'contato_telefone'
-- Data: 2026-02-05
-- =====================================================

DO $$ 
BEGIN
    -- Verificar se coluna 'contato' existe
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
          AND table_name = 'fornecedores' 
          AND column_name = 'contato'
    ) THEN
        RAISE NOTICE '✅ Coluna "contato" encontrada - será renomeada para "contato_telefone"';
        
        -- Renomear coluna
        ALTER TABLE fornecedores RENAME COLUMN contato TO contato_telefone;
        
        RAISE NOTICE '✅ Coluna renomeada com sucesso!';
    ELSE
        RAISE NOTICE '✅ Coluna "contato" não existe - verificando "contato_telefone"...';
        
        -- Verificar se contato_telefone já existe
        IF EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_schema = 'public' 
              AND table_name = 'fornecedores' 
              AND column_name = 'contato_telefone'
        ) THEN
            RAISE NOTICE '✅ Coluna "contato_telefone" já existe - nada a fazer';
        ELSE
            RAISE NOTICE '⚠️ Nenhuma das colunas existe - criando "contato_telefone"';
            ALTER TABLE fornecedores ADD COLUMN contato_telefone character varying;
            RAISE NOTICE '✅ Coluna "contato_telefone" criada!';
        END IF;
    END IF;
    
    -- Adicionar contato_nome se não existir
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
          AND table_name = 'fornecedores' 
          AND column_name = 'contato_nome'
    ) THEN
        RAISE NOTICE '⚠️ Coluna "contato_nome" não existe - criando...';
        ALTER TABLE fornecedores ADD COLUMN contato_nome character varying;
        RAISE NOTICE '✅ Coluna "contato_nome" criada!';
    ELSE
        RAISE NOTICE '✅ Coluna "contato_nome" já existe';
    END IF;
    
END $$;

-- Verificar estrutura final
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'fornecedores'
  AND column_name IN ('contato', 'contato_telefone', 'contato_nome')
ORDER BY column_name;
