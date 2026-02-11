-- =====================================================
-- SISTEMA DE PERMISSÕES DINÂMICAS POR USUÁRIO
-- =====================================================
-- Cada empresa tem seu próprio banco, então não precisa de empresa_id
-- Apenas armazenamos permissões do usuário para cada módulo

-- Tabela 1: Módulos disponíveis no sistema
CREATE TABLE IF NOT EXISTS modulos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome TEXT NOT NULL UNIQUE,
    descricao TEXT,
    slug TEXT NOT NULL UNIQUE,
    icone TEXT,
    ordem INT DEFAULT 0,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela 2: Permissões por Usuário (cada usuário tem suas permissões por módulo)
CREATE TABLE IF NOT EXISTS usuarios_modulos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL,
    modulo_id UUID NOT NULL REFERENCES modulos(id) ON DELETE CASCADE,
    pode_acessar BOOLEAN DEFAULT TRUE,
    pode_criar BOOLEAN DEFAULT FALSE,
    pode_editar BOOLEAN DEFAULT FALSE,
    pode_deletar BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(usuario_id, modulo_id)
);

-- Tabela 3: Ações customizáveis por Módulo (para funcionalidades futuras)
CREATE TABLE IF NOT EXISTS acoes_modulo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    modulo_id UUID NOT NULL REFERENCES modulos(id) ON DELETE CASCADE,
    nome TEXT NOT NULL,
    descricao TEXT,
    slug TEXT NOT NULL,
    UNIQUE(modulo_id, slug)
);

-- Tabela 4: Permissões de Ação por Usuário (para funcionalidades futuras)
CREATE TABLE IF NOT EXISTS permissoes_acoes_usuario (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL,
    acao_id UUID NOT NULL REFERENCES acoes_modulo(id) ON DELETE CASCADE,
    permitida BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(usuario_id, acao_id)
);

-- =====================================================
-- DADOS INICIAIS
-- =====================================================

-- Inserir módulos disponíveis
INSERT INTO modulos (nome, descricao, slug, icone, ordem, ativo) VALUES
    ('Dashboard', 'Painel de controle principal', 'dashboard', 'fas fa-chart-line', 1, TRUE),
    ('Produtos', 'Gerenciar produtos e catálogo', 'produtos', 'fas fa-box', 2, TRUE),
    ('Estoque', 'Controle de estoque e movimentação', 'estoque', 'fas fa-warehouse', 3, TRUE),
    ('Vendas', 'Gerenciar vendas e PDV', 'vendas', 'fas fa-receipt', 4, TRUE),
    ('Pedidos de Compra', 'Solicitar e acompanhar compras', 'pedidos-compra', 'fas fa-shopping-cart', 5, TRUE),
    ('Fornecedores', 'Gerenciar fornecedores', 'fornecedores', 'fas fa-truck', 6, TRUE),
    ('Clientes', 'Gerenciar clientes', 'clientes', 'fas fa-users', 7, TRUE),
    ('Análises Financeiras', 'Relatórios e análises', 'analises-financeiras', 'fas fa-chart-bar', 8, TRUE),
    ('Configurações', 'Configurações do sistema e empresa', 'configuracoes', 'fas fa-cog', 9, TRUE),
    ('Usuários', 'Gerenciar usuários e permissões', 'usuarios', 'fas fa-user-shield', 10, TRUE),
    ('PDV', 'Ponto de Venda', 'pdv', 'fas fa-cash-register', 11, TRUE)
ON CONFLICT (slug) DO NOTHING;

-- =====================================================
-- RLS POLICIES
-- =====================================================

ALTER TABLE modulos ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios_modulos ENABLE ROW LEVEL SECURITY;
ALTER TABLE acoes_modulo ENABLE ROW LEVEL SECURITY;
ALTER TABLE permissoes_acoes_usuario ENABLE ROW LEVEL SECURITY;

-- Permitir leitura pública de módulos
CREATE POLICY "Qualquer um lê módulos" ON modulos FOR SELECT USING (TRUE);

-- usuarios_modulos - Qualquer um lê (para verificar permissões)
CREATE POLICY "Qualquer um lê usuarios_modulos" ON usuarios_modulos FOR SELECT USING (TRUE);

-- Apenas usuários autenticados podem modificar (admin da empresa)
CREATE POLICY "Admin modifica permissões de usuários" ON usuarios_modulos FOR ALL USING (auth.uid() IS NOT NULL);

-- acoes_modulo - Leitura pública
CREATE POLICY "Qualquer um lê acoes_modulo" ON acoes_modulo FOR SELECT USING (TRUE);

-- permissoes_acoes_usuario - Leitura pública
CREATE POLICY "Qualquer um lê permissoes_acoes_usuario" ON permissoes_acoes_usuario FOR SELECT USING (TRUE);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_usuarios_modulos_usuario ON usuarios_modulos(usuario_id);
CREATE INDEX IF NOT EXISTS idx_usuarios_modulos_modulo ON usuarios_modulos(modulo_id);
CREATE INDEX IF NOT EXISTS idx_usuarios_modulos_usuario_modulo ON usuarios_modulos(usuario_id, modulo_id);
CREATE INDEX IF NOT EXISTS idx_acoes_modulo_modulo ON acoes_modulo(modulo_id);
CREATE INDEX IF NOT EXISTS idx_permissoes_acoes_usuario_usuario ON permissoes_acoes_usuario(usuario_id);

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================
