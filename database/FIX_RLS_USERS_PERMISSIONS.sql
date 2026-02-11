-- =====================================================
-- FIX: Corrigir RLS Policies na tabela users
-- =====================================================
-- EXECUTE NO SUPABASE SQL EDITOR
-- Isso vai permitir que usuários autenticados leiam e atualizem a tabela users

-- Passo 1: Habilitar RLS na tabela users
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Passo 2: Remover policies antigas (se existirem)
DROP POLICY IF EXISTS "Usuários autenticados leem users" ON public.users;
DROP POLICY IF EXISTS "Usuários autenticados atualizam users" ON public.users;
DROP POLICY IF EXISTS "Usuários inserem seu próprio perfil" ON public.users;
DROP POLICY IF EXISTS "Users can read all users" ON public.users;
DROP POLICY IF EXISTS "Users can update their own record" ON public.users;
DROP POLICY IF EXISTS "Users can insert their own record" ON public.users;

-- Passo 3: Criar policy de SELECT (qualquer usuario autenticado lê qualquer usuário)
CREATE POLICY "Qualquer autenticado lê todos users" ON public.users
FOR SELECT
USING (auth.uid() IS NOT NULL);

-- Passo 4: Criar policy de UPDATE (qualquer usuario autenticado atualiza qualquer usuário)
CREATE POLICY "Qualquer autenticado atualiza users" ON public.users
FOR UPDATE
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);

-- Passo 5: Criar policy de INSERT (cada usuario insere seu próprio registro)
CREATE POLICY "Usuário insere seu próprio perfil" ON public.users
FOR INSERT
WITH CHECK (id = auth.uid());

-- Passo 6: Verificar que as policies foram criadas
SELECT * FROM pg_policies WHERE tablename = 'users';

-- Resultado esperado: 3 políticas para a tabela users
-- ✅ Qualquer autenticado lê todos users
-- ✅ Qualquer autenticado atualiza users
-- ✅ Usuário insere seu próprio perfil
