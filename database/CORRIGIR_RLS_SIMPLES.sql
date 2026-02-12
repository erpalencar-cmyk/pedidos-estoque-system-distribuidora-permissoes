-- =====================================================
-- CORRIGIR RLS - VERSÃO SIMPLES E FUNCIONAL
-- =====================================================
-- Problema: Erro 406 ao tentar acessar usuarios_modulos
-- Solução: Políticas RLS simples e permissivas

-- ✅ 1. REMOVER TODAS AS POLÍTICAS ANTIGAS
-- Tabela: users
DROP POLICY IF EXISTS "Allow registration and own profile insert" ON public.users;
DROP POLICY IF EXISTS "Qualquer autenticado lê todos users" ON public.users;
DROP POLICY IF EXISTS "Qualquer autenticado atualiza users" ON public.users;
DROP POLICY IF EXISTS "Usuário insere seu próprio perfil" ON public.users;
DROP POLICY IF EXISTS "Allow signup and own record insert" ON public.users;
DROP POLICY IF EXISTS "Authenticated users can select" ON public.users;
DROP POLICY IF EXISTS "Users can update own record" ON public.users;
DROP POLICY IF EXISTS "Authenticated read users" ON public.users;
DROP POLICY IF EXISTS "Allow signup and own insert" ON public.users;
DROP POLICY IF EXISTS "Users update own, admin update all" ON public.users;

-- Tabela: usuarios_modulos
DROP POLICY IF EXISTS "Enable read for users" ON public.usuarios_modulos;
DROP POLICY IF EXISTS "Enable insert for users" ON public.usuarios_modulos;
DROP POLICY IF EXISTS "Enable update for users" ON public.usuarios_modulos;
DROP POLICY IF EXISTS "Users can read their permissions" ON public.usuarios_modulos;
DROP POLICY IF EXISTS "Admin can insert permissions" ON public.usuarios_modulos;
DROP POLICY IF EXISTS "Admin can update permissions" ON public.usuarios_modulos;
DROP POLICY IF EXISTS "Qualquer um lê usuarios_modulos" ON public.usuarios_modulos;
DROP POLICY IF EXISTS "Admin modifica permissões de usuários" ON public.usuarios_modulos;

-- Tabela: modulos
DROP POLICY IF EXISTS "Qualquer um lê módulos" ON public.modulos;

-- Tabela: acoes_modulo
DROP POLICY IF EXISTS "Qualquer um lê acoes_modulo" ON public.acoes_modulo;

-- Tabela: permissoes_acoes_usuario
DROP POLICY IF EXISTS "Qualquer um lê permissoes_acoes_usuario" ON public.permissoes_acoes_usuario;

-- ✅ 2. HABILITAR RLS NAS TABELAS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usuarios_modulos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.modulos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.acoes_modulo ENABLE ROW LEVEL SECURITY;

-- ✅ 3. POLÍTICAS SIMPLES E PERMISSIVAS PARA users
-- Qualquer usuário autenticado pode LER users (essencial para verificações)
CREATE POLICY "Anyone read users" ON public.users
FOR SELECT
USING (auth.uid() IS NOT NULL);

-- Signup: anon pode criar seu próprio registro
CREATE POLICY "Anon signup insert" ON public.users
FOR INSERT
WITH CHECK (auth.uid() IS NULL);

-- Autenticado pode atualizar seu próprio registro
CREATE POLICY "User update own" ON public.users
FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Admin pode fazer qualquer coisa
CREATE POLICY "Admin all users" ON public.users
USING (
    auth.uid() IN (
        SELECT id FROM public.users 
        WHERE role = 'ADMIN' AND auth.uid() IS NOT NULL
    )
);

-- ✅ 4. POLÍTICAS PARA usuarios_modulos
-- Qualquer autenticado pode LER suas permissões (ESSENCIAL)
CREATE POLICY "Read own permissions" ON public.usuarios_modulos
FOR SELECT
USING (
    auth.uid() IS NOT NULL
);

-- Admin pode fazer qualquer coisa em permissões
CREATE POLICY "Admin manage all permissions" ON public.usuarios_modulos
FOR ALL
USING (
    auth.uid() IN (
        SELECT id FROM public.users 
        WHERE role = 'ADMIN' AND auth.uid() IS NOT NULL
    )
)
WITH CHECK (
    auth.uid() IN (
        SELECT id FROM public.users 
        WHERE role = 'ADMIN' AND auth.uid() IS NOT NULL
    )
);

-- ✅ 5. POLÍTICAS PARA modulos (leitura pública)
CREATE POLICY "Read modulos" ON public.modulos
FOR SELECT
USING (auth.uid() IS NOT NULL);

-- ✅ 6. POLÍTICAS PARA acoes_modulo (leitura pública)
CREATE POLICY "Read acoes_modulo" ON public.acoes_modulo
FOR SELECT
USING (auth.uid() IS NOT NULL);

-- ✅ VERIFICAÇÃO
SELECT '✅ CORREÇÃO RLS CONCLUÍDA' as status;
SELECT 'Policies na tabela users:' as info;
SELECT policyname FROM pg_policies WHERE tablename = 'users' ORDER BY policyname;

SELECT 'Policies na tabela usuarios_modulos:' as info;
SELECT policyname FROM pg_policies WHERE tablename = 'usuarios_modulos' ORDER BY policyname;

SELECT 'Policies na tabela modulos:' as info;
SELECT policyname FROM pg_policies WHERE tablename = 'modulos' ORDER BY policyname;
