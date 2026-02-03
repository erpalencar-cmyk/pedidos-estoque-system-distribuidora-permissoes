-- ================================================================
-- DESABILITAR RLS - TESTE TEMPORÁRIO
-- ================================================================
-- Data: Fevereiro 3, 2026
-- Propósito: Desabilitar RLS em todas as tabelas para teste
-- ⚠️ USAR APENAS EM DESENVOLVIMENTO/TESTE
-- ================================================================

-- Desabilitar RLS em TODAS as tabelas
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE produto_lotes DISABLE ROW LEVEL SECURITY;
ALTER TABLE fornecedores DISABLE ROW LEVEL SECURITY;
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE categorias DISABLE ROW LEVEL SECURITY;
ALTER TABLE marcas DISABLE ROW LEVEL SECURITY;
ALTER TABLE caixas DISABLE ROW LEVEL SECURITY;
ALTER TABLE movimentacoes_caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE vendas DISABLE ROW LEVEL SECURITY;
ALTER TABLE vendas_itens DISABLE ROW LEVEL SECURITY;
ALTER TABLE estoque_movimentacoes DISABLE ROW LEVEL SECURITY;
ALTER TABLE pagamentos_venda DISABLE ROW LEVEL SECURITY;
ALTER TABLE contas_receber DISABLE ROW LEVEL SECURITY;
ALTER TABLE documentos_fiscais DISABLE ROW LEVEL SECURITY;
ALTER TABLE auditoria_log DISABLE ROW LEVEL SECURITY;
ALTER TABLE empresa_config DISABLE ROW LEVEL SECURITY;

-- ================================================================
-- ✅ PRONTO - RLS DESABILITADO EM TODAS AS TABELAS
-- ================================================================

/*
Agora você pode fazer login sem problemas de RLS.

DEPOIS DE TESTAR O LOGIN COM SUCESSO:
1. Execute o script 04-REABILITAR_RLS_SEGURO.sql para reabilitar RLS
   com políticas mais simples e seguras
*/

COMMIT;
