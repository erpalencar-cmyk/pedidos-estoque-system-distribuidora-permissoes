-- Script para verificar e garantir que caixa_sessoes tem todas as colunas necessárias

-- Verificar estrutura de caixa_sessoes
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'caixa_sessoes'
ORDER BY ordinal_position;

-- Contar registros
SELECT COUNT(*) as total_sessoes FROM caixa_sessoes;

-- Verificar se há caixas disponíveis
SELECT id, numero, nome, ativo FROM caixas WHERE ativo = true LIMIT 5;
