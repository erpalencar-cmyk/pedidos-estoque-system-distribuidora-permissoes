-- Script para limpar dados órfãos e recriar foreign keys com sucesso

-- Passo 1: Remover foreign keys existentes
ALTER TABLE caixa_sessoes DROP CONSTRAINT IF EXISTS fk_caixa_sessoes_caixa;
ALTER TABLE caixa_sessoes DROP CONSTRAINT IF EXISTS fk_caixa_sessoes_operador;

-- Passo 2: Limpar registros órfãos em caixa_sessoes
-- Remover registros que referenciam caixas que não existem
DELETE FROM caixa_sessoes 
WHERE caixa_id NOT IN (SELECT id FROM caixas) OR caixa_id IS NULL;

-- Remover registros que referenciam users que não existem
DELETE FROM caixa_sessoes 
WHERE operador_id NOT IN (SELECT id FROM users) OR operador_id IS NULL;

-- Passo 3: Tornar as colunas NOT NULL apenas se houver dados
-- Se ainda há registros órfãos, vamos permitir NULL temporariamente
ALTER TABLE caixa_sessoes 
ALTER COLUMN caixa_id DROP NOT NULL;

ALTER TABLE caixa_sessoes 
ALTER COLUMN operador_id DROP NOT NULL;

-- Passo 4: Recriar foreign keys sem restricções
ALTER TABLE caixa_sessoes 
ADD CONSTRAINT fk_caixa_sessoes_caixa 
FOREIGN KEY (caixa_id) REFERENCES caixas(id) ON DELETE SET NULL;

ALTER TABLE caixa_sessoes 
ADD CONSTRAINT fk_caixa_sessoes_operador 
FOREIGN KEY (operador_id) REFERENCES users(id) ON DELETE SET NULL;

-- Passo 5: Verificar dados após limpeza
SELECT 
    'Total de sessões restantes' as info,
    COUNT(*) as quantidade
FROM caixa_sessoes;

SELECT 
    'Sessões com caixa inválida' as info,
    COUNT(*) as quantidade
FROM caixa_sessoes 
WHERE caixa_id NOT IN (SELECT id FROM caixas);

SELECT 
    'Sessões com operador inválido' as info,
    COUNT(*) as quantidade
FROM caixa_sessoes 
WHERE operador_id NOT IN (SELECT id FROM users);

SELECT 'Script concluído com sucesso!' as resultado;
