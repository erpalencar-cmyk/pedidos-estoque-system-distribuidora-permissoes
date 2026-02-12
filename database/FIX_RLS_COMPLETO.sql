-- =====================================================
-- FIX: Corrigir RLS para funcionar com Multi-tenant
-- =====================================================
-- Execute no Supabase SQL Editor

-- ✅ 1. Remover policies antigas da tabela users
DROP POLICY IF EXISTS "Allow registration and own profile insert" ON public.users;
DROP POLICY IF EXISTS "Qualquer autenticado lê todos users" ON public.users;
DROP POLICY IF EXISTS "Qualquer autenticado atualiza users" ON public.users;
DROP POLICY IF EXISTS "Usuário insere seu próprio perfil" ON public.users;
DROP POLICY IF EXISTS "Allow signup and own record insert" ON public.users;
DROP POLICY IF EXISTS "Authenticated users can select" ON public.users;
DROP POLICY IF EXISTS "Users can update own record" ON public.users;

-- ✅ 2. Habilitar RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- ✅ 3. CREATE POLICY - Todos podem ler (essencial para a aplicação)
CREATE POLICY "Authenticated read users" ON public.users
FOR SELECT
USING (auth.uid() IS NOT NULL);

-- ✅ 4. INSERT POLICY - Anon durante signup, ou autenticado
CREATE POLICY "Allow signup and own insert" ON public.users
FOR INSERT
WITH CHECK (
    (auth.uid() IS NULL) OR 
    (id = auth.uid())
);

-- ✅ 5. UPDATE POLICY - Próprio usuário ou ADMIN
CREATE POLICY "Users update own, admin update all" ON public.users
FOR UPDATE
USING (
    auth.uid() = id OR 
    auth.uid() IN (SELECT id FROM users WHERE role = 'ADMIN')
)
WITH CHECK (
    auth.uid() = id OR 
    auth.uid() IN (SELECT id FROM users WHERE role = 'ADMIN')
);

-- ============================================ =======
-- FIX: Corrigir RLS na tabela usuarios_modulos
-- =====================================================

-- ✅ 6. Remover policies antigas
DROP POLICY IF EXISTS "Enable read for users" ON public.usuarios_modulos;
DROP POLICY IF EXISTS "Enable insert for users" ON public.usuarios_modulos;
DROP POLICY IF EXISTS "Enable update for users" ON public.usuarios_modulos;

-- ✅ 7. Habilitar RLS
ALTER TABLE public.usuarios_modulos ENABLE ROW LEVEL SECURITY;

-- ✅ 8. SELECT - Autenticado pode ver suas próprias permissões
CREATE POLICY "Users can read their permissions" ON public.usuarios_modulos
FOR SELECT
USING (
    auth.uid() = usuario_id OR
    auth.uid() IN (SELECT id FROM users WHERE role = 'ADMIN')
);

-- ✅ 9. INSERT - Admin pode inserir (para gerenciar-permissoes.html)
CREATE POLICY "Admin can insert permissions" ON public.usuarios_modulos
FOR INSERT
WITH CHECK (
    auth.uid() IN (SELECT id FROM users WHERE role = 'ADMIN')
);

-- ✅ 10. UPDATE - Admin pode atualizar
CREATE POLICY "Admin can update permissions" ON public.usuarios_modulos
FOR UPDATE
USING (
    auth.uid() IN (SELECT id FROM users WHERE role = 'ADMIN')
)
WITH CHECK (
    auth.uid() IN (SELECT id FROM users WHERE role = 'ADMIN')
);

-- ============================================
-- VERIFICAÇÃO
-- =====================================================
-- Após executar, verifique com:
SELECT '📋 USERS Policies:' as status;
SELECT schemaname, tablename, policyname FROM pg_policies WHERE tablename = 'users' ORDER BY tablename, policyname;

SELECT '📋 USUARIOS_MODULOS Policies:' as status;
SELECT schemaname, tablename, policyname FROM pg_policies WHERE tablename = 'usuarios_modulos' ORDER BY tablename, policyname;
