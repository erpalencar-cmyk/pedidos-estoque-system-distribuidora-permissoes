-- ================================================================
-- REABILITAR RLS - SEGURO E SIMPLES
-- ================================================================
-- Data: Fevereiro 3, 2026
-- Propósito: Reabilitar RLS com políticas simples após teste
-- Execute DEPOIS que confirmar que o login funciona
-- ================================================================

-- ================================================================
-- REABILITAR RLS EM TODAS AS TABELAS
-- ================================================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE produto_lotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE fornecedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE marcas ENABLE ROW LEVEL SECURITY;
ALTER TABLE caixas ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimentacoes_caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE estoque_movimentacoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE pagamentos_venda ENABLE ROW LEVEL SECURITY;
ALTER TABLE contas_receber ENABLE ROW LEVEL SECURITY;
ALTER TABLE documentos_fiscais ENABLE ROW LEVEL SECURITY;
ALTER TABLE auditoria_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE empresa_config ENABLE ROW LEVEL SECURITY;

-- ================================================================
-- REMOVER TODAS AS POLICIES ANTIGAS
-- ================================================================

-- Users
DROP POLICY IF EXISTS "Usuários autenticados podem ler" ON users;
DROP POLICY IF EXISTS "Usuários podem se cadastrar" ON users;
DROP POLICY IF EXISTS "Apenas ADMIN pode gerenciar usuários" ON users;
DROP POLICY IF EXISTS "Apenas ADMIN pode deletar usuários" ON users;
DROP POLICY IF EXISTS "Usuários podem ver outros usuários ativos" ON users;
DROP POLICY IF EXISTS "Usuários podem ver seus próprios dados" ON users;

-- Produtos
DROP POLICY IF EXISTS "Usuários podem ver produtos ativos" ON produtos;
DROP POLICY IF EXISTS "ADMIN e COMPRADOR podem criar produtos" ON produtos;

-- Fornecedores
DROP POLICY IF EXISTS "Usuários podem ver fornecedores ativos" ON fornecedores;
DROP POLICY IF EXISTS "ADMIN e COMPRADOR podem criar fornecedores" ON fornecedores;

-- Clientes
DROP POLICY IF EXISTS "Usuários podem ver clientes ativos" ON clientes;
DROP POLICY IF EXISTS "ADMIN e COMPRADOR podem criar clientes" ON clientes;

-- ================================================================
-- CRIAR POLICIES SIMPLES E PERMISSIVAS
-- ================================================================

-- USERS: Qualquer autenticado pode ler, ADMIN pode alterar
CREATE POLICY "auth_users_read"
    ON users FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "auth_users_insert"
    ON users FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id);

CREATE POLICY "admin_users_update"
    ON users FOR UPDATE
    TO authenticated
    USING (
        EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'ADMIN')
    );

CREATE POLICY "admin_users_delete"
    ON users FOR DELETE
    TO authenticated
    USING (
        EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'ADMIN')
    );

-- PRODUTOS: Qualquer autenticado pode ler, ADMIN/COMPRADOR podem escrever
CREATE POLICY "auth_produtos_read"
    ON produtos FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "admin_produtos_write"
    ON produtos FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('ADMIN', 'COMPRADOR'))
    );

CREATE POLICY "admin_produtos_update"
    ON produtos FOR UPDATE
    TO authenticated
    USING (
        EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('ADMIN', 'COMPRADOR'))
    );

-- FORNECEDORES: Qualquer autenticado pode ler, ADMIN/COMPRADOR podem escrever
CREATE POLICY "auth_fornecedores_read"
    ON fornecedores FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "admin_fornecedores_write"
    ON fornecedores FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('ADMIN', 'COMPRADOR'))
    );

CREATE POLICY "admin_fornecedores_update"
    ON fornecedores FOR UPDATE
    TO authenticated
    USING (
        EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('ADMIN', 'COMPRADOR'))
    );

-- CLIENTES: Qualquer autenticado pode ler, ADMIN/COMPRADOR/VENDEDOR podem escrever
CREATE POLICY "auth_clientes_read"
    ON clientes FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "admin_clientes_write"
    ON clientes FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('ADMIN', 'COMPRADOR', 'VENDEDOR'))
    );

CREATE POLICY "admin_clientes_update"
    ON clientes FOR UPDATE
    TO authenticated
    USING (
        EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('ADMIN', 'COMPRADOR', 'VENDEDOR'))
    );

-- CATEGORIAS: Apenas ADMIN pode escrever, qualquer um pode ler
CREATE POLICY "auth_categorias_read"
    ON categorias FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "admin_categorias_write"
    ON categorias FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'ADMIN')
    );

-- MARCAS: Apenas ADMIN pode escrever, qualquer um pode ler
CREATE POLICY "auth_marcas_read"
    ON marcas FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "admin_marcas_write"
    ON marcas FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'ADMIN')
    );

-- CAIXAS: Qualquer autenticado pode ler
CREATE POLICY "auth_caixas_read"
    ON caixas FOR SELECT
    TO authenticated
    USING (true);

-- VENDAS: Qualquer autenticado pode ler/escrever (rastrear por auditoria)
CREATE POLICY "auth_vendas_read"
    ON vendas FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "auth_vendas_insert"
    ON vendas FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- ESTOQUE: Qualquer autenticado pode ler
CREATE POLICY "auth_estoque_movimentacoes_read"
    ON estoque_movimentacoes FOR SELECT
    TO authenticated
    USING (true);

-- DOCUMENTOS_FISCAIS: Qualquer autenticado pode ler/escrever
CREATE POLICY "auth_documentos_fiscais_read"
    ON documentos_fiscais FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "auth_documentos_fiscais_insert"
    ON documentos_fiscais FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- AUDITORIA_LOG: Apenas ADMIN pode ler
CREATE POLICY "admin_auditoria_read"
    ON auditoria_log FOR SELECT
    TO authenticated
    USING (
        EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'ADMIN')
    );

-- EMPRESA_CONFIG: Qualquer autenticado pode ler, ADMIN pode escrever
CREATE POLICY "auth_empresa_config_read"
    ON empresa_config FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "admin_empresa_config_update"
    ON empresa_config FOR UPDATE
    TO authenticated
    USING (
        EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'ADMIN')
    );

-- ================================================================
-- ✅ RLS REABILITADO COM POLÍTICAS SIMPLES
-- ================================================================

/*
Políticas ativadas:
- Usuários autenticados podem ler a maioria das tabelas
- ADMIN pode modificar dados críticos
- COMPRADOR pode gerenciar produtos e fornecedores
- VENDEDOR pode gerenciar clientes
- Auditoria é restrita a ADMIN

Se ainda tiver problemas, execute:
ALTER TABLE [table_name] DISABLE ROW LEVEL SECURITY;
para desabilitar RLS em uma tabela específica
*/

COMMIT;
