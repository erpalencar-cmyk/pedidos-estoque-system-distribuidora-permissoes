-- ================================================================
-- REFERÊNCIA RÁPIDA - EXECUÇÃO SCRIPTS NO BANCO
-- ================================================================
-- Copie e cole cada comando um por vez no Supabase SQL Editor
-- ================================================================

-- 📍 STEP 1 - VERIFICAR CONEXÃO
-- Execute primeiro para confirmar que consegue acessar o banco
SELECT NOW() as hora_servidor,
       current_database() as banco_atual,
       current_user as usuario_conectado;

-- ================================================================
-- 📍 STEP 2 - EXECUTAR LIMPEZA (RECOMENDADO)
-- ================================================================
-- Se tem schema antigo, execute: database/00-LIMPAR_BANCO.sql
-- Se é primeira vez, pode pular
-- Tempo: ~5 segundos

-- Depois de executar 00-LIMPAR_BANCO.sql, verif pode se:
-- SELECT * FROM information_schema.tables 
-- WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
-- (Deve retornar 0 linhas)

-- ================================================================
-- 📍 STEP 3 - CRIAR SCHEMA NOVO (OBRIGATÓRIO)
-- ================================================================
-- Execute: database/schema-novo-distribuidora.sql
-- Tempo: ~5 segundos
-- Cria: 17 tabelas, 4 functions, 9 triggers, 3 views, extensões

-- Verificar após execução:
SELECT COUNT(*) as total_tabelas 
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
-- Deve retornar: 17

-- Verificar dados iniciais:
SELECT 'Categorias' as tabela, COUNT(*) as qtd FROM categorias
UNION ALL
SELECT 'Marcas', COUNT(*) FROM marcas
UNION ALL
SELECT 'Caixas', COUNT(*) FROM caixas;
-- Deve retornar: 8, 10, 3

-- ================================================================
-- 📍 STEP 4 - CRIAR PROCEDURES (OBRIGATÓRIO)
-- ================================================================
-- Execute: database/stored-procedures-novo.sql
-- Tempo: ~2 segundos
-- Cria: finalizar_venda_segura() e outras

-- Verificar após execução:
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' AND routine_type = 'FUNCTION'
ORDER BY routine_name;
-- Deve incluir: finalizar_venda_segura

-- ================================================================
-- 📋 TESTES RÁPIDOS (Execute um de cada vez)
-- ================================================================

-- ✅ Teste 1: Inserir dados de teste
INSERT INTO empresa_config (
    nome_empresa,
    razao_social,
    cnpj,
    nome_empresa,
    email
) VALUES (
    'DISTRIBUIDORA TESTE',
    'Distribuidora Teste LTDA',
    '12.345.678/0001-90',
    'Distribuidora Teste',
    'contato@teste.com'
)
ON CONFLICT (cnpj) DO NOTHING;

-- Verificar:
SELECT nome_empresa, cnpj FROM empresa_config;

-- ✅ Teste 2: Criar usuário teste
INSERT INTO users (
    email,
    nome_completo,
    cpf,
    role
) VALUES (
    'operador@teste.com',
    'Operador Teste',
    '123.456.789-00',
    'OPERADOR_CAIXA'
)
ON CONFLICT (email) DO NOTHING;

-- Verificar:
SELECT email, nome_completo, role FROM users;

-- ✅ Teste 3: Criar cliente
INSERT INTO clientes (
    nome,
    tipo,
    cpf_cnpj,
    email,
    limite_credito
) VALUES (
    'Cliente Teste',
    'PF',
    '123.456.789-00',
    'cliente@teste.com',
    1000.00
)
ON CONFLICT (cpf_cnpj) DO NOTHING;

-- ✅ Teste 4: Inserir produto
INSERT INTO produtos (
    sku,
    codigo_barras,
    nome,
    categoria_id,
    marca_id,
    preco_custo,
    preco_venda,
    estoque_minimo,
    estoque_maximo,
    estoque_atual
) VALUES (
    'SKU-001',
    '1234567890123',
    'Produto Teste',
    (SELECT id FROM categorias LIMIT 1),
    (SELECT id FROM marcas LIMIT 1),
    10.00,
    15.00,
    5,
    50,
    20
);

-- ✅ Teste 5: Abrir caixa
INSERT INTO movimentacoes_caixa (
    caixa_id,
    operador_id,
    saldo_inicial,
    status
) VALUES (
    (SELECT id FROM caixas LIMIT 1),
    (SELECT id FROM users WHERE role = 'OPERADOR_CAIXA' LIMIT 1),
    100.00,
    'ABERTA'
);

-- ✅ Teste 6: Finalizar venda (usar procedure com lock)
SELECT finalizar_venda_segura(
    'PED-20250203-000001',
    (SELECT id FROM caixas LIMIT 1),
    (SELECT id FROM movimentacoes_caixa WHERE status = 'ABERTA' LIMIT 1),
    (SELECT id FROM users WHERE role = 'OPERADOR_CAIXA' LIMIT 1),
    15.00,      -- subtotal
    0.00,       -- desconto
    0.00,       -- acrescimo
    15.00,      -- total
    'DINHEIRO',
    20.00,      -- valor pago
    5.00        -- troco
);

-- Verificar vendas criadas:
SELECT numero_nf, subtotal, total, status_venda FROM vendas;

-- ✅ Teste 7: Verificar auditoria
SELECT tabela_nome, operacao, usuario_id, created_at 
FROM auditoria_log 
ORDER BY created_at DESC 
LIMIT 5;

-- ✅ Teste 8: Consultar view de estoque crítico
SELECT * FROM v_estoque_critico;

-- ✅ Teste 9: Consultar view de vendas do dia
SELECT * FROM v_vendas_do_dia;

-- ================================================================
-- 🔍 QUERIES ÚTEIS PARA DEBUG
-- ================================================================

-- Listar todas as tabelas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Listar todas as views
SELECT table_name 
FROM information_schema.views 
WHERE table_schema = 'public';

-- Listar todas as functions
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_schema = 'public'
ORDER BY routine_name;

-- Listar triggers
SELECT trigger_name, trigger_schema
FROM information_schema.triggers 
WHERE trigger_schema = 'public'
ORDER BY trigger_name;

-- Contar registros em todas as tabelas
SELECT 
    'categorias' as tabela, COUNT(*) as qtd FROM categorias
UNION ALL SELECT 'marcas', COUNT(*) FROM marcas
UNION ALL SELECT 'produtos', COUNT(*) FROM produtos
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'clientes', COUNT(*) FROM clientes
UNION ALL SELECT 'caixas', COUNT(*) FROM caixas
UNION ALL SELECT 'movimentacoes_caixa', COUNT(*) FROM movimentacoes_caixa
UNION ALL SELECT 'vendas', COUNT(*) FROM vendas
UNION ALL SELECT 'vendas_itens', COUNT(*) FROM vendas_itens;

-- Verificar espaço em disco
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as tamanho
FROM pg_tables 
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- ================================================================
-- ⚠️ COMANDOS PERIGOSOS (Usar com cuidado)
-- ================================================================

-- Limpar todos os dados (MANTÉM ESTRUTURA)
-- DELETE FROM auditoria_log;
-- DELETE FROM documentos_fiscais;
-- DELETE FROM estoque_movimentacoes;
-- DELETE FROM pagamentos_venda;
-- DELETE FROM contas_receber;
-- DELETE FROM vendas_itens;
-- DELETE FROM vendas;
-- DELETE FROM movimentacoes_caixa;
-- DELETE FROM produto_lotes;
-- DELETE FROM produtos;
-- DELETE FROM clientes;
-- DELETE FROM fornecedores;

-- Reset de sequence
-- ALTER SEQUENCE vendas_numero_seq RESTART WITH 1001;

-- ================================================================
-- 📞 TROUBLESHOOTING
-- ================================================================

-- Erro: "Type user_role does not exist"
-- Solução: Execute 00-LIMPAR_BANCO.sql primeiro

-- Erro: "Duplicate key value violates unique constraint"
-- Solução: Dados já existem, use ON CONFLICT DO NOTHING

-- Erro: "Permission denied"
-- Solução: Verificar RLS policy, confirmar role do usuário

-- Erro: "Race condition na venda"
-- Solução: Usar finalizar_venda_segura() que tem LOCK implícito

-- ================================================================
-- ✅ CHECKLIST FINAL
-- ================================================================

-- [ ] Schema criado com 17 tabelas
-- [ ] 4 functions criadas
-- [ ] 9 triggers ativados
-- [ ] 3 views funcionando
-- [ ] 4 RLS policies ativas
-- [ ] Dados iniciais presentes (categorias, marcas, caixas)
-- [ ] Procedura finalizar_venda_segura() testada
-- [ ] Usuários de teste criados
-- [ ] Teste de auditoria executado
-- [ ] Sistema pronto para produção

-- ================================================================
-- 📚 DOCUMENTAÇÃO
-- ================================================================
-- Arquivo: GUIA_IMPLEMENTACAO_BANCO.md
-- Leia antes de executar para entender o fluxo completo
-- ================================================================
