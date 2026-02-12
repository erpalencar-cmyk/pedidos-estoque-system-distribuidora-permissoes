-- =====================================================
-- INSERIR MÓDULOS - BASEADO NO SIDEBAR REAL
-- =====================================================
-- Mapeamento inteligente dos menu items do sidebar
-- para slugs de módulos no banco de dados

INSERT INTO modulos (nome, descricao, slug, icone, ordem, ativo) VALUES
    -- SEÇÃO: Dashboard
    ('Dashboard', 'Painel de controle principal', 'dashboard', 'fas fa-chart-line', 1, TRUE),
    
    -- SEÇÃO: Produtos e Estoque
    ('Produtos', 'Gerenciar produtos e catálogo', 'produtos', 'fas fa-box', 2, TRUE),
    ('Estoque', 'Controle de estoque e movimentação', 'estoque', 'fas fa-warehouse', 3, TRUE),
    ('Controle de Validade', 'Monitorar produtos com vencimento próximo', 'controle-validade', 'fas fa-calendar-alt', 4, TRUE),
    
    -- SEÇÃO: Vendas
    ('PDV', 'Ponto de Venda e caixas', 'pdv', 'fas fa-cash-register', 5, TRUE),
    ('Comandas', 'Gerenciar comandas de atendimento', 'comandas', 'fas fa-list', 6, TRUE),
    ('Vendas', 'Gerenciar vendas e consultas', 'vendas', 'fas fa-receipt', 7, TRUE),
    ('Caixas', 'Configurar e gerenciar caixas do PDV', 'caixas', 'fas fa-boxes', 8, TRUE),
    
    -- SEÇÃO: Relacionamento Comercial
    ('Clientes', 'Gerenciar clientes', 'clientes', 'fas fa-users', 9, TRUE),
    ('Fornecedores', 'Gerenciar fornecedores', 'fornecedores', 'fas fa-truck', 10, TRUE),
    
    -- SEÇÃO: Compras
    ('Pedidos de Compra', 'Solicitar e acompanhar compras', 'pedidos-compra', 'fas fa-shopping-cart', 11, TRUE),
    
    -- SEÇÃO: Financeiro
    ('Contas a Pagar', 'Gerenciar contas para pagar', 'contas-pagar', 'fas fa-file-invoice-dollar', 12, TRUE),
    ('Contas a Receber', 'Gerenciar contas para receber', 'contas-receber', 'fas fa-hand-holding-usd', 13, TRUE),
    ('Análise Financeira', 'Relatórios e análises financeiras', 'analise-financeira', 'fas fa-chart-bar', 14, TRUE),
    
    -- SEÇÃO: Fiscal
    ('Documentos Fiscais', 'Gerenciar notas fiscais emitidas', 'documentos-fiscais', 'fas fa-file-pdf', 15, TRUE),
    ('Distribuição NFC-e', 'Distribuir NFC-e aos clientes', 'distribuicao-nfce', 'fas fa-share-alt', 16, TRUE),
    
    -- SEÇÃO: Administração
    ('Usuários', 'Gerenciar usuários e acesso', 'usuarios', 'fas fa-user-shield', 17, TRUE),
    ('Aprovar Usuários', 'Aprovar novos registros de usuários', 'aprovacao-usuarios', 'fas fa-check-circle', 18, TRUE),
    ('Gerenciar Permissões', 'Configurar permissões por módulo', 'gerenciar-permissoes', 'fas fa-lock', 19, TRUE),
    ('Configurações', 'Configurações da empresa', 'configuracoes', 'fas fa-cog', 20, TRUE)
ON CONFLICT (slug) DO NOTHING;

-- ✅ VERIFICAÇÃO: Deve inserir 20 módulos
SELECT 'Módulos inseridos com sucesso!' as info, COUNT(*) as total FROM modulos;
SELECT id, ordem, slug, nome FROM modulos ORDER BY ordem;
