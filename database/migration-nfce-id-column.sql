-- Migração: Adicionar coluna nfce_id para armazenar ID Nuvem Fiscal em documentos_fiscais
-- Data: 2026-02-09
-- Descrição: Permite armazenar o ID único da NFC-e na Nuvem Fiscal para download do XML

-- Adicionar coluna nfce_id
ALTER TABLE public.documentos_fiscais
ADD COLUMN IF NOT EXISTS nfce_id varchar(100) NULL
COMMENT 'ID único da NFC-e na Nuvem Fiscal (usado para download do XML)';

-- Criar índice para busca rápida (se precisar sincronizar/actualizar em lote)
CREATE INDEX IF NOT EXISTS idx_documentos_fiscais_nfce_id 
ON public.documentos_fiscais USING btree (nfce_id) 
WHERE nfce_id IS NOT NULL;

-- Verificação (para validar que foi criado corretamente)
-- SELECT column_name, data_type, is_nullable 
-- FROM information_schema.columns 
-- WHERE table_name = 'documentos_fiscais' AND column_name = 'nfce_id';
