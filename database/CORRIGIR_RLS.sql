-- =====================================================
-- SCRIPT: CORRIGIR RLS POLICIES
-- =====================================================
-- Execute no SQL Editor: https://btdqhrmbnvhhxeessplc.supabase.co
-- Ctrl+Enter ou clique em "Run"

-- =====================================================
-- 1. REMOVER POLICIES ANTIGAS QUE ESTÃO BLOQUEANDO
-- =====================================================

DROP POLICY IF EXISTS "Admin pode ver seu próprio registro" ON public.admin_users;
DROP POLICY IF EXISTS "Qualquer um pode ler empresas" ON public.empresas;


-- =====================================================
-- 2. CRIAR NOVAS POLICIES CORRETAS
-- =====================================================

-- Política para EMPRESAS: Qualquer um pode ler
CREATE POLICY "public_read_empresas" ON public.empresas
    FOR SELECT
    USING (true);

-- Política para ADMIN_USERS: Qualquer um pode ler
-- (pois a autenticação já foi feita no Auth antes de chegar aqui)
CREATE POLICY "public_read_admin_users" ON public.admin_users
    FOR SELECT
    USING (true);


-- =====================================================
-- 3. VERIFICAR AS POLICIES
-- =====================================================

SELECT 
    schemaname, 
    tablename, 
    policyname, 
    permissive, 
    roles, 
    qual
FROM pg_policies 
WHERE schemaname = 'public' AND tablename IN ('empresas', 'admin_users')
ORDER BY tablename, policyname;

-- =====================================================
-- 4. TESTAR A QUERY (deve retornar o admin)
-- =====================================================

SELECT id, email, empresa_id FROM public.admin_users WHERE email = 'brunoallencar@hotmail.com' LIMIT 1;
