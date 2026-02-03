-- Script para VERIFICAR E DIAGNOSTICAR o schema das tabelas no Supabase
-- Execute cada query uma por uma no Supabase SQL Editor

-- ========================================
-- 1. Verificar se coluna TROCO existe em VENDAS
-- ========================================
SELECT EXISTS (
    SELECT FROM information_schema.columns 
    WHERE table_name = 'vendas' 
    AND column_name = 'troco'
) as "Coluna TROCO Existe?";

-- Resultado esperado: true ou false

-- ========================================
-- 2. Ver TODAS as colunas da tabela VENDAS
-- ========================================
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'vendas'
ORDER BY ordinal_position;

-- Resultado esperado: Lista de todas as colunas incluindo 'troco'

-- ========================================
-- 3. Verificar se tabela VENDAS existe
-- ========================================
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_name = 'vendas'
) as "Tabela VENDAS Existe?";

-- ========================================
-- 4. Contar quantas linhas temos em VENDAS
-- ========================================
SELECT COUNT(*) as total_vendas FROM vendas;

-- ========================================
-- 5. Ver uma venda completa (para debug)
-- ========================================
SELECT * FROM vendas LIMIT 1;

-- Resultado esperado: 
-- - Deve mostrar todos os campos incluindo 'troco'
-- - Se der erro "column 'troco' does not exist", a coluna ainda não foi criada

-- ========================================
-- 6. Verificar índices na tabela VENDAS
-- ========================================
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'vendas';

-- Resultado esperado: Deve incluir idx_vendas_troco se foi criado

-- ========================================
-- 7. Ver estrutura completa de VENDAS
-- ========================================
\d vendas

-- ou

SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'vendas'
ORDER BY ordinal_position;

-- ========================================
-- SE AINDA NÃO TIVER, EXECUTE ISTO:
-- ========================================
-- Adicionar coluna troco se ainda não existe
ALTER TABLE vendas ADD COLUMN IF NOT EXISTS troco DECIMAL(12,2) DEFAULT 0;

-- Criar índice para performance
CREATE INDEX IF NOT EXISTS idx_vendas_troco ON vendas(troco);

-- Verificar que foi criado
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'vendas' AND column_name = 'troco';

-- Resultado esperado: troco (mostra que a coluna foi criada)

