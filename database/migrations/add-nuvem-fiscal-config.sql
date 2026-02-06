-- ============================================
-- Migração: Adicionar suporte para Nuvem Fiscal
-- Data: 2024
-- Descrição: Adiciona campos para armazenar credenciais OAuth2 da Nuvem Fiscal e seleção de provedor de API fiscal
-- ============================================

-- Adicionar campos de configuração da Nuvem Fiscal na tabela empresa_config
ALTER TABLE empresa_config
ADD COLUMN IF NOT EXISTS nuvemfiscal_client_id TEXT,
ADD COLUMN IF NOT EXISTS nuvemfiscal_client_secret TEXT,
ADD COLUMN IF NOT EXISTS nuvemfiscal_access_token TEXT,
ADD COLUMN IF NOT EXISTS nuvemfiscal_token_expiry TIMESTAMP,
ADD COLUMN IF NOT EXISTS api_fiscal_provider VARCHAR(20) DEFAULT 'focus_nfe' CHECK (api_fiscal_provider IN ('focus_nfe', 'nuvem_fiscal'));

-- Adicionar comentários para documentação
COMMENT ON COLUMN empresa_config.nuvemfiscal_client_id IS 'Client ID da API Nuvem Fiscal (OAuth2)';
COMMENT ON COLUMN empresa_config.nuvemfiscal_client_secret IS 'Client Secret da API Nuvem Fiscal (OAuth2)';
COMMENT ON COLUMN empresa_config.nuvemfiscal_access_token IS 'Access Token OAuth2 em cache';
COMMENT ON COLUMN empresa_config.nuvemfiscal_token_expiry IS 'Data/hora de expiração do access token';
COMMENT ON COLUMN empresa_config.api_fiscal_provider IS 'Provedor de API fiscal a ser utilizado: focus_nfe ou nuvem_fiscal';

-- Índice para melhorar performance de consultas por provedor
CREATE INDEX IF NOT EXISTS idx_empresa_config_api_provider ON empresa_config(api_fiscal_provider);

-- Se houver tokens antigos, remover (campo obsoleto)
ALTER TABLE empresa_config DROP COLUMN IF EXISTS nuvemfiscal_token;
