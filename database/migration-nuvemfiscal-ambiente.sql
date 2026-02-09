-- =====================================================
-- MIGRATION: Adicionar campo nuvemfiscal_ambiente
-- =====================================================
-- Data: 2026-02-09
-- Descrição: Corrigir conflito de ambiente na Nuvem Fiscal
-- =====================================================

-- Passo 1: Adicionar coluna (se não existir)
ALTER TABLE empresa_config
ADD COLUMN IF NOT EXISTS nuvemfiscal_ambiente INTEGER 
  DEFAULT 2
  CHECK (nuvemfiscal_ambiente IN (1, 2))
  COMMENT 'Ambiente para Nuvem Fiscal: 1=Produção, 2=Homologação';

-- Passo 2: Backup dos valores atuais (opcional, para diagnóstico)
-- SELECT id, cnpj, nuvemfiscal_ambiente, nfce_ambiente, focusnfe_ambiente FROM empresa_config;

-- Passo 3: IMPORTANTE - Definir valor correto para sua empresa
-- ⚠️ SUBSTITUA ABAIXO COM O VALOR CORRETO!
-- Se está emitindo notas REAIS no SEFAZ:
UPDATE empresa_config
SET nuvemfiscal_ambiente = 1  -- 1 = Produção
WHERE nuvemfiscal_ambiente IS NULL;

-- Se está apenas testando (homologação):
-- UPDATE empresa_config
-- SET nuvemfiscal_ambiente = 2  -- 2 = Homologação
-- WHERE nuvemfiscal_ambiente IS NULL;

-- Passo 4: Verificar resultado
-- SELECT cnpj, nuvemfiscal_ambiente, nfce_ambiente, focusnfe_ambiente FROM empresa_config;

-- =====================================================
-- NOTAS IMPORTANTES:
-- =====================================================
-- 1. Cada PROVIDER (Focus NFe, Nuvem Fiscal) pode estar em ambiente DIFERENTE
-- 2. Ordem de prioridade no código:
--    - nuvemfiscal_ambiente (NOVO, específico)
--    - nfce_ambiente (genérico NFC-e)
--    - focusnfe_ambiente (genérico Focus, fallback)
-- 3. Se sua empresa está em PRODUÇÃO na Nuvem Fiscal: use 1
-- 4. Se sua empresa está em HOMOLOGAÇÃO na Nuvem Fiscal: use 2
-- =====================================================
