-- Script para corrigir a coluna ID em caixa_sessoes (versão com DROP CASCADE)

-- Passo 1: Verificar estado atual
SELECT column_name, data_type, column_default, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'caixa_sessoes' AND column_name = 'id';

-- Passo 2: Remover constraint com CASCADE para remover dependências
ALTER TABLE caixa_sessoes DROP CONSTRAINT IF EXISTS caixa_sessoes_pkey CASCADE;

-- Passo 3: Remover coluna ID antiga
ALTER TABLE caixa_sessoes DROP COLUMN IF EXISTS id;

-- Passo 4: Adicionar coluna ID nova com DEFAULT
ALTER TABLE caixa_sessoes ADD COLUMN id UUID PRIMARY KEY DEFAULT uuid_generate_v4();

-- Passo 5: Recriar foreign keys se necessário
-- Remover constraints antigas se existirem
ALTER TABLE caixa_movimentacoes DROP CONSTRAINT IF EXISTS caixa_movimentacoes_sessao_id_fkey;

-- Recriar constraint
ALTER TABLE caixa_movimentacoes 
ADD CONSTRAINT caixa_movimentacoes_sessao_id_fkey 
FOREIGN KEY (sessao_id) REFERENCES caixa_sessoes(id) ON DELETE CASCADE;

-- Passo 6: Verificar novamente
SELECT column_name, data_type, column_default, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'caixa_sessoes' 
ORDER BY ordinal_position;

SELECT 'Script concluído com sucesso!' as resultado;

