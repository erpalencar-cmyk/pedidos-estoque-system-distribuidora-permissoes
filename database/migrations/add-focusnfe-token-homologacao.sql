-- =====================================================
-- MIGRATION: Adicionar campo de token Focus NFe Homologação
-- =====================================================
-- Data: 05/02/2026
-- Objetivo: Separar tokens de produção e homologação
-- =====================================================

-- Adicionar novo campo para token de homologação
ALTER TABLE public.empresa_config 
ADD COLUMN IF NOT EXISTS focusnfe_token_homologacao TEXT;

-- Comentários para documentação
COMMENT ON COLUMN public.empresa_config.focusnfe_token IS 'Token Focus NFe para ambiente de PRODUÇÃO';
COMMENT ON COLUMN public.empresa_config.focusnfe_token_homologacao IS 'Token Focus NFe para ambiente de HOMOLOGAÇÃO';

-- Nota: O campo focusnfe_token existente passa a ser usado para PRODUÇÃO
-- O novo campo focusnfe_token_homologacao será usado para HOMOLOGAÇÃO
