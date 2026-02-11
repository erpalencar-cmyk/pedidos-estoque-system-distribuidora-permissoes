-- Migration: Adicionar coluna empresa_id na tabela users
-- Description: Permite rastrear qual empresa um usuário foi registrado
-- Date: 2026-02-11

ALTER TABLE public.users
ADD COLUMN empresa_id uuid NULL;

-- Criar índice para melhorar performance de queries
CREATE INDEX idx_users_empresa_id ON public.users USING btree (empresa_id);

-- Adicionar comentário na coluna
COMMENT ON COLUMN public.users.empresa_id IS 'ID da empresa a qual o usuário está vinculado';
