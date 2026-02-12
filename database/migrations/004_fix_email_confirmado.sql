-- ============================================================
-- Migration 004: Corrigir usuários com email não confirmado
-- Problema 1: auth.users tem email_confirmed_at = NULL (Supabase bloqueia login)
-- Problema 2: public.users tem email_confirmado = false (não aparece para aprovação)
-- Solução: Confirmar email em AMBAS as tabelas
-- ============================================================

-- 1. Confirmar email na tabela auth.users (RESOLVE o erro "Email not confirmed")
UPDATE auth.users 
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;

-- 2. Confirmar email na tabela public.users (permite aparecer na aprovação)
UPDATE public.users 
SET email_confirmado = true 
WHERE email_confirmado = false OR email_confirmado IS NULL;

-- Verificação
-- SELECT id, email, email_confirmed_at FROM auth.users;
-- SELECT id, email, email_confirmado, approved, ativo FROM public.users;
