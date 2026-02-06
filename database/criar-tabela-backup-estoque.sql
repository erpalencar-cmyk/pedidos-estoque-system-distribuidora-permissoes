-- ==========================================
-- CRIAR TABELA DE BACKUP DE ESTOQUE
-- Execute isso no Supabase SQL Editor
-- ==========================================

CREATE TABLE IF NOT EXISTS public.estoque_backups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    data_backup TIMESTAMP WITH TIME ZONE DEFAULT now(),
    total_produtos INTEGER,
    total_unidades NUMERIC,
    dados_backup JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Criar índice para buscar rapidamente
CREATE INDEX IF NOT EXISTS idx_estoque_backups_data_backup 
ON public.estoque_backups(data_backup DESC);

-- Habilitar RLS (Row Level Security)
ALTER TABLE public.estoque_backups ENABLE ROW LEVEL SECURITY;

-- Política para usuários autenticados lerem seus backups
CREATE POLICY "Authenticated users can view estoque_backups"
ON public.estoque_backups
FOR SELECT
USING (auth.role() = 'authenticated');

-- Política para usuários autenticados criarem backups
CREATE POLICY "Authenticated users can create estoque_backups"
ON public.estoque_backups
FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

-- Adicionar comentário na tabela
COMMENT ON TABLE public.estoque_backups IS 'Backup de estoque antes de reprocessamento - contém snapshot JSON dos produtos e suas quantidades';

-- Mostrar confirmação
SELECT 'Tabela estoque_backups criada com sucesso!' as mensagem;
