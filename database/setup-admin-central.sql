-- =====================================================
-- SCRIPT: CRIAR TABELA EMPRESAS
-- =====================================================
-- Executar no Supabase Central: https://btdqhrmbnvhhxeessplc.supabase.co

CREATE TABLE IF NOT EXISTS empresas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    cnpj VARCHAR(20) NOT NULL UNIQUE,
    supabase_url TEXT NOT NULL,
    supabase_anon_key TEXT NOT NULL,
    logo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índice para buscar por CNPJ
CREATE INDEX IF NOT EXISTS idx_empresas_cnpj ON empresas(cnpj);

-- =====================================================
-- SCRIPT: CRIAR TABELA ADMIN_USERS
-- =====================================================

CREATE TABLE IF NOT EXISTS admin_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índice para buscar por email
CREATE INDEX IF NOT EXISTS idx_admin_users_email ON admin_users(email);
CREATE INDEX IF NOT EXISTS idx_admin_users_empresa_id ON admin_users(empresa_id);

-- =====================================================
-- HABILITAR RLS (Row Level Security)
-- =====================================================

ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Política: Qualquer pessoa autenticada pode ler empresas
CREATE POLICY "Qualquer um pode ler empresas"
    ON empresas FOR SELECT
    USING (true);

-- Política: Apenas admins podem ver seu próprio admin_users
CREATE POLICY "Admin pode ver seu próprio registro"
    ON admin_users FOR SELECT
    USING (auth.uid()::text = id::text);

-- =====================================================
-- INSERIR USUÁRIO ADMIN DE TESTE
-- =====================================================
-- Após criar o usuário em Authentication > Users primeiro!

-- Copie e cole isso DEPOIS de criar o usuário brunoallencar@hotmail.com no Supabase Auth

-- 1. Primeiro create no Auth > Users com email brunoallencar@hotmail.com e senha Bb93163087@@

-- 2. Depois execute isto para criar a empresa:
INSERT INTO empresas (nome, cnpj, supabase_url, supabase_anon_key, logo_url)
VALUES (
    'Distribuidora Bruno Allencar',
    '12.345.678/0001-99',
    'https://seu-supabase-da-empresa.supabase.co',
    'sb_his_anon_key_aqui',
    NULL
) ON CONFLICT (cnpj) DO NOTHING;

-- 3. Depois execute isto (substitua o UUID da empresa caso necessário):
-- Primeiro obtenha o ID da empresa que foi criada:
-- SELECT id FROM empresas WHERE cnpj = '12.345.678/0001-99';

-- Depois use esse ID aqui:
INSERT INTO admin_users (email, empresa_id)
SELECT 'brunoallencar@hotmail.com', id 
FROM empresas 
WHERE cnpj = '12.345.678/0001-99'
ON CONFLICT (email) DO NOTHING;

-- =====================================================
-- VERIFICAR DADOS INSERIDOS
-- =====================================================

SELECT * FROM empresas;
SELECT * FROM admin_users;
