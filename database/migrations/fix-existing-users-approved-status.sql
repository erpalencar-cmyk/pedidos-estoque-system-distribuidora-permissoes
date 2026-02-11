-- Script para corrigir usuários existentes com status inconsistente
-- Data: 2026-02-11
-- Descrição: Marcar como aprovado todos os usuários que estão ativos mas não foram aprovados

UPDATE public.users
SET approved = true, approved_at = now()
WHERE ativo = true AND approved = false;

-- Verificar resultado
SELECT email, ativo, email_confirmado, approved FROM public.users WHERE ativo = true;
