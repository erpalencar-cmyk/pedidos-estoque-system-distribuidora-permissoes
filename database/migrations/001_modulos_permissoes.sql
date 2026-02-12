-- =====================================================
-- MIGRATION 001: Módulos e Sistema de Permissões
-- =====================================================
-- Popula a tabela public.modulos com todos os módulos do sistema
-- Adiciona FK faltante em usuarios_modulos
-- Deve ser executada em cada banco de empresa (Supabase project)
-- =====================================================

-- 1) Popular tabela modulos com todos os módulos do sidebar
-- Usa lógica de upsert que trata conflito tanto em slug quanto em nome
-- Também trata slugs legados (renomeados) via mapeamento explícito
DO $$
DECLARE
    r RECORD;
    v_legacy_slug TEXT;
BEGIN
    -- Passo 0: Corrigir slugs legados ANTES do loop principal
    -- Isso garante que o UPDATE por slug funcione para módulos renomeados
    FOR r IN
        SELECT * FROM (VALUES
            ('analises-financeiras',  'analise-financeira'),
            ('configuracoes',         'configuracoes-empresa')
        ) AS t(old_slug, new_slug)
    LOOP
        -- Só renomear se o slug antigo existir E o novo NÃO existir
        IF EXISTS (SELECT 1 FROM public.modulos WHERE slug = r.old_slug)
           AND NOT EXISTS (SELECT 1 FROM public.modulos WHERE slug = r.new_slug) THEN
            UPDATE public.modulos SET slug = r.new_slug WHERE slug = r.old_slug;
            RAISE NOTICE 'Slug legado corrigido: % → %', r.old_slug, r.new_slug;
        END IF;
    END LOOP;

    -- Passo 1: Inserir/atualizar módulos
    FOR r IN
        SELECT * FROM (VALUES
            ('Dashboard',               'dashboard',            'fas fa-chart-line',          1,  true, 'Painel principal com visão geral'),
            ('Produtos',                'produtos',             'fas fa-box',                 10, true, 'Cadastro e gestão de produtos'),
            ('Fornecedores',            'fornecedores',         'fas fa-building',            11, true, 'Cadastro e gestão de fornecedores'),
            ('Clientes',                'clientes',             'fas fa-users',               12, true, 'Cadastro e gestão de clientes'),
            ('Usuários',                'usuarios',             'fas fa-user-friends',        13, true, 'Gerenciamento de usuários do sistema'),
            ('Gerenciar Permissões',    'gerenciar-permissoes', 'fas fa-user-lock',           14, true, 'Configuração de permissões por usuário'),
            ('Caixas',                  'caixas',               'fas fa-cash-register',       15, true, 'Gerenciamento de caixas registradoras'),
            ('Aprovação de Usuários',   'aprovacao-usuarios',   'fas fa-user-check',          16, true, 'Aprovação de novos cadastros'),
            ('Configurações da Empresa','configuracoes-empresa','fas fa-cog',                 17, true, 'Configurações gerais da empresa'),
            ('PDV - Caixa',             'pdv',                  'fas fa-calculator',          20, true, 'Ponto de venda / Caixa'),
            ('Comandas',                'comandas',             'fas fa-file-alt',            21, true, 'Sistema de comandas'),
            ('Estoque',                 'estoque',              'fas fa-warehouse',           30, true, 'Controle de estoque'),
            ('Controle de Validade',    'controle-validade',    'fas fa-calendar-alt',        31, true, 'Gestão de validade de produtos'),
            ('Pedidos de Compra',       'pedidos',              'fas fa-shopping-bag',        32, true, 'Pedidos de compra a fornecedores'),
            ('Vendas',                  'vendas',               'fas fa-shopping-cart',       33, true, 'Consulta e gestão de vendas'),
            ('Vendas Pendentes',        'vendas-pendentes',     'fas fa-dollar-sign',         34, true, 'Vendas com pagamento pendente'),
            ('Conferência de Vendas',   'conferencia-vendas',   'fas fa-clipboard-check',     35, true, 'Conferência e separação de vendas'),
            ('Aprovações',              'aprovacao',            'fas fa-check-circle',        36, true, 'Aprovação de pedidos e operações'),
            ('Pré-Pedidos Públicos',    'pre-pedidos',          'fas fa-globe',               37, true, 'Gestão de pré-pedidos públicos'),
            ('Contas a Pagar',          'contas-pagar',         'fas fa-money-bill',          40, true, 'Controle de contas a pagar'),
            ('Contas a Receber',        'contas-receber',       'fas fa-hand-holding-usd',    41, true, 'Controle de contas a receber'),
            ('Análise Financeira',      'analise-financeira',   'fas fa-chart-bar',           42, true, 'Relatórios e análises financeiras'),
            ('Documentos Fiscais',      'documentos-fiscais',   'fas fa-file-invoice',        50, true, 'Gestão de documentos fiscais'),
            ('Distribuição de NFC-e',   'distribuicao-nfce',    'fas fa-cloud-download-alt',  51, true, 'Distribuição de notas NFC-e'),
            ('Testes Focus NFe',        'teste-focus-nfe',      'fas fa-clipboard-check',     52, true, 'Testes de integração Focus NFe'),
            ('Testes Nuvem Fiscal',     'teste-nuvem-fiscal',   'fas fa-cloud',               53, true, 'Testes de integração Nuvem Fiscal'),
            ('Reprocessar Estoque',     'reprocessar-estoque',  'fas fa-sync',                60, true, 'Reprocessamento de estoque')
        ) AS t(nome, slug, icone, ordem, ativo, descricao)
    LOOP
        -- Tentar atualizar pela slug (identificador principal)
        UPDATE public.modulos
        SET nome = r.nome, icone = r.icone, ordem = r.ordem, ativo = r.ativo, descricao = r.descricao
        WHERE slug = r.slug;

        IF NOT FOUND THEN
            -- Slug não existe: tentar atualizar pelo nome (módulo existente com slug diferente)
            UPDATE public.modulos
            SET slug = r.slug, icone = r.icone, ordem = r.ordem, ativo = r.ativo, descricao = r.descricao
            WHERE nome = r.nome;

            IF NOT FOUND THEN
                -- Módulo totalmente novo: inserir
                INSERT INTO public.modulos (nome, slug, icone, ordem, ativo, descricao)
                VALUES (r.nome, r.slug, r.icone, r.ordem, r.ativo, r.descricao);
            END IF;
        END IF;
    END LOOP;

    RAISE NOTICE 'Módulos sincronizados com sucesso.';
END $$;

-- 2) Adicionar FK faltante: usuarios_modulos.usuario_id → users.id
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'usuarios_modulos_usuario_id_fkey'
        AND table_name = 'usuarios_modulos'
    ) THEN
        ALTER TABLE public.usuarios_modulos
        ADD CONSTRAINT usuarios_modulos_usuario_id_fkey
        FOREIGN KEY (usuario_id) REFERENCES public.users(id) ON DELETE CASCADE;
    END IF;
END $$;

-- 3) Conceder automaticamente TODAS as permissões para usuários ADMIN existentes
-- Isso garante que admins não percam acesso ao aplicar o novo sistema
INSERT INTO public.usuarios_modulos (usuario_id, modulo_id, pode_acessar, pode_criar, pode_editar, pode_deletar)
SELECT u.id, m.id, true, true, true, true
FROM public.users u
CROSS JOIN public.modulos m
WHERE u.role = 'ADMIN'
ON CONFLICT (usuario_id, modulo_id) DO UPDATE SET
    pode_acessar = true,
    pode_criar = true,
    pode_editar = true,
    pode_deletar = true;

-- 4) Índice para melhor performance nas consultas de permissão
CREATE INDEX IF NOT EXISTS idx_usuarios_modulos_usuario_acesso 
ON public.usuarios_modulos (usuario_id, pode_acessar) 
WHERE pode_acessar = true;
