-- =====================================================
-- FIX: Adicionar RLS Policies para tabela users
-- =====================================================
-- Para permitir que usuários autenticados leiam e atualizem a tabela users

-- Habilitar RLS na tabela users (se ainda não estiver habilitado)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Qualquer usuário autenticado pode ler todos os usuários
CREATE POLICY "Usuários autenticados leem users" ON users
FOR SELECT
USING (auth.uid() IS NOT NULL);

-- Policy: Qualquer usuário autenticado pode atualizar qualquer usuário
CREATE POLICY "Usuários autenticados atualizam users" ON users
FOR UPDATE
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);

-- Policy: Apenas o próprio usuário pode inserir dados (para signup)
CREATE POLICY "Usuários inserem seu próprio perfil" ON users
FOR INSERT
WITH CHECK (id = auth.uid());

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================
