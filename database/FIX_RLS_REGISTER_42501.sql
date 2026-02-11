-- =====================================================
-- FIX: Corrigir erro 42501 durante registro (INSERT policy)
-- =====================================================
-- EXECUTE NO SUPABASE SQL EDITOR
-- Problema: Durante o registro, o usuário não está autenticado, 
-- então auth.uid() = NULL e a policy bloqueia a inserção

-- ✅ Solução 1: Permitir ANON (não autenticados) inserirem durante registro
-- Este é o RECOMENDADO para registro funcionar corretamente

-- Passo 1: Remover a política de INSERT antiga
DROP POLICY IF EXISTS "Usuário insere seu próprio perfil" ON public.users;

-- Passo 2: Criar nova policy que permite:
-- - Anon (não autenticado) inserir SEM CHECK (durante registro)
-- - Autenticado atualizar sua própria linha
CREATE POLICY "Allow registration and own profile insert" ON public.users
FOR INSERT
WITH CHECK (
    -- Permitir anon (signup) OU autenticado inserindo sua própria linha
    (auth.uid() IS NULL) OR (id = auth.uid())
);

-- ✅ Solução 2 (alternativa): Se a solução 1 não funcionar
-- Execute esta para fazer com que o service_role faça a inserção
-- (descomente se precisar usar uma função trigger):
/*
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name, nome_completo, role, whatsapp, ativo, email_confirmado, approved)
  VALUES (NEW.id, NEW.email, NEW.email, NEW.email, 'COMPRADOR', NULL, true, false, false)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
*/

-- Verificação
SELECT '✅ RLS Policy atualizada com sucesso!' as status;
