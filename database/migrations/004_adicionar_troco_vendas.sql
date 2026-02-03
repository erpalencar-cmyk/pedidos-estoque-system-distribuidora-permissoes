-- Migration: Adicionar coluna TROCO na tabela VENDAS
-- Este script adiciona a coluna 'troco' que estava faltando na tabela vendas

BEGIN;

-- Adicionar coluna troco se não existir
ALTER TABLE vendas ADD COLUMN IF NOT EXISTS troco DECIMAL(12,2) DEFAULT 0;

-- Criar índice para melhor performance
CREATE INDEX IF NOT EXISTS idx_vendas_troco ON vendas(troco);

COMMIT;
