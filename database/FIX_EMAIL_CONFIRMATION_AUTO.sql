-- =====================================================
-- FIX: Remover requisito de confirmação de email no Supabase
-- =====================================================
-- EXECUTE NO SUPABASE SQL EDITOR

-- ✅ Opção 1: AUTOMÁTICA - Criar trigger que confirma email ao registrar
-- (Recomendado: simples e funciona bem)

CREATE OR REPLACE FUNCTION public.confirm_email_on_signup()
RETURNS TRIGGER AS $$
BEGIN
  -- Confirmar automaticamente o email ao criar novo usuário
  UPDATE auth.users 
  SET email_confirmed_at = NOW()
  WHERE id = NEW.id 
  AND email_confirmed_at IS NULL;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar trigger na tabela auth.users
DROP TRIGGER IF EXISTS confirm_email_trigger ON auth.users;
CREATE TRIGGER confirm_email_trigger
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.confirm_email_on_signup();

-- ✅ Verificação
SELECT '✅ Trigger de confirmação automática de email criado!' as status;

-- =====================================================
-- TESTE: Depois de executar o SQL acima
-- =====================================================
-- 1. Tente registrar um novo usuário no formulário
-- 2. Depois de registrar, tente fazer LOGIN imediatamente (sem esperar email)
-- 3. Deveria funcionar sem erro "Email not confirmed"

-- Se ainda não funcionar, use a OPÇÃO 2 abaixo

-- =====================================================
-- ✅ Opção 2: CONFIGURAÇÃO DO SUPABASE (se Opção 1 não funcionar)
-- =====================================================
-- Como desabilitar confirmação de email no Supabase:
-- 
-- 1. Vá para: https://app.supabase.com
-- 2. Selecione seu projeto
-- 3. Vá em: Authentication (Auth) → Providers → Email
-- 4. Procure a opção "Confirm email" ou "Email confirmation required"
-- 5. DESABILITE essa opção
-- 6. Salve as mudanças
-- 
-- Isso vai permitir login sem confirmação de email

-- =====================================================
-- Se precisar confirmar email MANUALMENTE para um usuário específico:
-- =====================================================
-- UPDATE auth.users 
-- SET email_confirmed_at = NOW()
-- WHERE email = 'usuario@email.com';
