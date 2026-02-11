-- =====================================================
-- SCRIPT COMPLETO: CRIAR ADMIN + EMPRESA
-- =====================================================
-- Copie TUDO este script e execute no SQL Editor do Supabase
-- https://btdqhrmbnvhhxeessplc.supabase.co > SQL Editor
-- Cole, execute e pronto!

-- =====================================================
-- 1. CRIAR TABELAS (se ainda não existirem)
-- =====================================================

CREATE TABLE IF NOT EXISTS empresas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    cnpj VARCHAR(20) NOT NULL UNIQUE,
    supabase_url TEXT NOT NULL,
    supabase_anon_key TEXT NOT NULL,
    logo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS admin_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 2. HABILITAR RLS
-- =====================================================

ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Remover policies antigas (se existirem)
DROP POLICY IF EXISTS "Qualquer um pode ler empresas" ON empresas;
DROP POLICY IF EXISTS "Admin pode ver seu próprio registro" ON admin_users;

-- Criar policies novas
CREATE POLICY "Qualquer um pode ler empresas" ON empresas 
    FOR SELECT USING (true);

CREATE POLICY "Admin pode ver seu próprio registro" ON admin_users 
    FOR SELECT USING (auth.uid()::text = id::text);

-- =====================================================
-- 3. INSERIR EMPRESA
-- =====================================================

INSERT INTO empresas (nome, cnpj, supabase_url, supabase_anon_key)
VALUES (
    'Distribuidora Bruno Allencar',
    '12.345.678/0001-99',
    'https://uyyyxblwffzonczrtqjy.supabase.co',
    'sb_publishable_uGN5emN1tfqTgTudDZJM-g_Qc4YKIj_'
)
ON CONFLICT (cnpj) DO NOTHING;

-- =====================================================
-- 4. INSERIR ADMIN_USER
-- =====================================================

INSERT INTO admin_users (email, empresa_id)
SELECT 
    'brunoallencar@hotmail.com',
    id 
FROM empresas 
WHERE cnpj = '12.345.678/0001-99'
ON CONFLICT (email) DO NOTHING;

-- =====================================================
-- 5. VERIFICAR (execute estes SELECTs para confirmar)
-- =====================================================

-- Ver empresas criadas
SELECT id, nome, cnpj FROM empresas;

-- Ver admins criados
SELECT email, empresa_id FROM admin_users;

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================
