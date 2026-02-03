-- ================================================================
-- LIMPEZA COMPLETA DO BANCO - Remover todos os dados e estruturas
-- ================================================================
-- Execute este script ANTES de executar o schema novo
-- Ele remove: dados, views, funções, tipos, extensões
-- ================================================================

-- ======================== REMOVER RLS (Row Level Security) ==========================
-- Remover policies primeiro
DO $$
BEGIN
    -- Remover policies se existirem
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users' AND table_schema = 'public') THEN
        DROP POLICY IF EXISTS users_read_own_data ON users;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'vendas' AND table_schema = 'public') THEN
        DROP POLICY IF EXISTS vendas_read_by_role ON vendas;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'estoque_movimentacoes' AND table_schema = 'public') THEN
        DROP POLICY IF EXISTS estoque_mov_read_own_data ON estoque_movimentacoes;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'auditoria_log' AND table_schema = 'public') THEN
        DROP POLICY IF EXISTS audit_read_own_data ON auditoria_log;
    END IF;
    
    -- Desabilitar RLS
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'auditoria_log' AND table_schema = 'public') THEN
        ALTER TABLE auditoria_log DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'estoque_movimentacoes' AND table_schema = 'public') THEN
        ALTER TABLE estoque_movimentacoes DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'vendas' AND table_schema = 'public') THEN
        ALTER TABLE vendas DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users' AND table_schema = 'public') THEN
        ALTER TABLE users DISABLE ROW LEVEL SECURITY;
    END IF;
END $$;

-- ======================== REMOVER VIEWS ==========================
DROP VIEW IF EXISTS v_contas_receber_vencidas CASCADE;
DROP VIEW IF EXISTS v_estoque_critico CASCADE;
DROP VIEW IF EXISTS v_vendas_do_dia CASCADE;

-- ======================== REMOVER TRIGGERS ==========================
-- Remover todos os triggers (IF EXISTS protege contra tabelas inexistentes)
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT trigger_name, event_object_table FROM information_schema.triggers 
              WHERE trigger_schema = 'public') 
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I CASCADE', r.trigger_name, r.event_object_table);
    END LOOP;
END $$;

-- ======================== REMOVER EXTENSÕES (PRIMEIRO!) ==========================
-- Remover extensões ANTES de functions (isso remove functions da extensão automaticamente)
DROP EXTENSION IF EXISTS pgcrypto CASCADE;
DROP EXTENSION IF EXISTS "uuid-ossp" CASCADE;

-- ======================== REMOVER FUNCTIONS ==========================
-- Remover functions customizadas (extensões já foram removidas acima)
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT routine_name 
              FROM information_schema.routines
              WHERE routine_schema = 'public' AND routine_type = 'FUNCTION'
              AND routine_name NOT LIKE 'pg_%')
    LOOP
        EXECUTE format('DROP FUNCTION IF EXISTS %I CASCADE', r.routine_name);
    END LOOP;
END $$;

-- ======================== REMOVER TABELAS ==========================
-- Remover todas as tabelas (IF EXISTS protege)
DROP TABLE IF EXISTS auditoria_log CASCADE;
DROP TABLE IF EXISTS documentos_fiscais CASCADE;
DROP TABLE IF EXISTS contas_receber CASCADE;
DROP TABLE IF EXISTS pagamentos_venda CASCADE;
DROP TABLE IF EXISTS estoque_movimentacoes CASCADE;
DROP TABLE IF EXISTS vendas_itens CASCADE;
DROP TABLE IF EXISTS vendas CASCADE;
DROP TABLE IF EXISTS movimentacoes_caixa CASCADE;
DROP TABLE IF EXISTS caixas CASCADE;
DROP TABLE IF EXISTS produto_lotes CASCADE;
DROP TABLE IF EXISTS produtos CASCADE;
DROP TABLE IF EXISTS marcas CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;
DROP TABLE IF EXISTS fornecedores CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS empresa_config CASCADE;

-- ======================== REMOVER SEQUENCES ==========================
DROP SEQUENCE IF EXISTS vendas_numero_seq CASCADE;

-- ======================== REMOVER TIPOS CUSTOMIZADOS ==========================
DROP TYPE IF EXISTS user_role CASCADE;
DROP TYPE IF EXISTS venda_status CASCADE;
DROP TYPE IF EXISTS documento_fiscal_status CASCADE;
DROP TYPE IF EXISTS pagamento_forma CASCADE;
DROP TYPE IF EXISTS unidade_medida CASCADE;

-- ======================== CONFIRMAÇÃO ==========================
SELECT 'LIMPEZA CONCLUÍDA!' as status,
       'Todos as tabelas, funções, triggers, tipos e extensões foram removidos' as mensagem,
       'Agora execute: schema-novo-distribuidora.sql' as proximo_passo;

-- COMMIT;
