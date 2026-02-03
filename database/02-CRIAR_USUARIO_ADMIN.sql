-- ================================================================
-- CRIAR PRIMEIRO USUÁRIO ADMIN
-- ================================================================
-- Data: Fevereiro 3, 2026
-- Propósito: Inserir usuário admin inicial no banco de dados
-- ================================================================

-- ⚠️ IMPORTANTE: LEIA ANTES DE EXECUTAR
/*
🔑 ENTENDA O PROCESSO:

Este sistema usa SUPABASE AUTH para gerenciar login e senha.
NÃO é feito no banco de dados (SQL).

FLUXO CORRETO:
┌─────────────────────────────────────────────────────────────┐
│ PASSO 1: Criar usuário NO SUPABASE AUTH CONSOLE              │
│ (Define email E SENHA que o usuário vai usar para login)     │
│                                                              │
│ PASSO 2: Executar ESTE SCRIPT SQL                           │
│ (Registra o usuário na tabela users do banco)               │
│                                                              │
│ PASSO 3: Fazer LOGIN com email + senha configurados no P1   │
└─────────────────────────────────────────────────────────────┘

⚠️ SE PULAR O PASSO 1 E EXECUTAR APENAS ESTE SCRIPT:
   ❌ O usuário NÃO conseguirá fazer login!
   ❌ A autenticação vai falhar porque não existe no Auth!

═══════════════════════════════════════════════════════════════

PASSO 1: CRIAR USUÁRIO NO SUPABASE AUTH (OBRIGATÓRIO)
═══════════════════════════════════════════════════════════════

Opção A: Via Console Supabase (RECOMENDADO - mais fácil)
───────────────────────────────────────────────────────
1. Acesse: https://app.supabase.com/
2. Selecione seu projeto
3. Vá para: Authentication → Users
4. Clique em "Create new user" (ou "Invite user")
5. Preencha:
   📧 Email: admin@distribuidora.com
   🔐 Password: SenhaForte@123456  ← ⚠️ GUARDE ESTA SENHA!
   ☑️ Auto Confirm User: MARQUE (para não precisar confirmar por email)
6. Clique em "Create user"
7. Será gerado um UUID automaticamente (não precisa copiar, o SQL gera outro)

Opção B: Via Supabase CLI (se tiver instalado)
───────────────────────────────────────────────
$ supabase auth admin create-user \
    --email admin@distribuidora.com \
    --password "SenhaForte@123456"

═══════════════════════════════════════════════════════════════

PASSO 2: EXECUTAR ESTE SCRIPT SQL
═══════════════════════════════════════════════════════════════

Depois de criar no Auth acima ↑ (NECESSÁRIO!)
Execute este script no Supabase SQL Editor:

1. Copie TODO o conteúdo deste arquivo
2. Abra: https://app.supabase.com/ → seu projeto → SQL Editor
3. Cole o conteúdo
4. Clique em "Run"

O script vai criar o registro na tabela users.

═══════════════════════════════════════════════════════════════

PASSO 3: FAZER LOGIN
═══════════════════════════════════════════════════════════════

1. Abra: http://localhost:seu-site/pages/auth.html (ou seu domínio)
2. Email: admin@distribuidora.com
3. Senha: SenhaForte@123456  (a que você definiu no PASSO 1)
4. Clique em "Login"

✅ Pronto! Você está logado como ADMIN
*/

-- ================================================================
-- ⚠️ RESUMO EXECUTIVO: ONDE A SENHA É DEFINIDA?
-- ================================================================

/*
❓ "Onde defino a senha neste script?"
✅ Resposta: NÃO É NESTE SCRIPT!

🔐 A SENHA É DEFINIDA NO SUPABASE AUTH CONSOLE (passo 1)

Este script SQL (passo 2) APENAS registra o usuário na tabela users.

SEQUÊNCIA CORRETA:
  ┌────────────────────────────────────────┐
  │ 1️⃣  SUPABASE AUTH CONSOLE              │
  │     └─ Criar usuário + DEFINA SENHA    │
  │        Email: admin@distribuidora.com  │
  │        Senha: SenhaForte@123456        │ ← DEFINA AQUI!
  │        Auto Confirm: ☑️                │
  │        → Clique em "Create user"       │
  └────────────────────────────────────────┘
                    ↓ DEPOIS
  ┌────────────────────────────────────────┐
  │ 2️⃣  ESTE SCRIPT SQL                    │
  │     └─ Execute no SQL Editor           │
  │        (registra na tabela users)      │
  └────────────────────────────────────────┘
                    ↓ DEPOIS
  ┌────────────────────────────────────────┐
  │ 3️⃣  FAZER LOGIN                        │
  │     └─ Use email + senha do passo 1️⃣  │
  │        admin@distribuidora.com         │
  │        SenhaForte@123456               │
  └────────────────────────────────────────┘

*/

-- ================================================================
-- ⚡ ATALHO: USUÁRIO JÁ EXISTE? TORNAR ADMIN!
-- ================================================================

/*
Se o usuário já está registrado na tabela users,
você pode torná-lo ADMIN com este comando simples:
*/

UPDATE users 
SET role = 'ADMIN'::user_role, 
    updated_at = NOW()
WHERE email = 'brunoallencar@hotmail.com';

-- Verificar que foi atualizado
SELECT id, email, nome_completo, role, ativo 
FROM users 
WHERE email = 'brunoallencar@hotmail.com';

-- ✅ Pronto! brunoallencar@hotmail.com agora é ADMIN!

INSERT INTO users (
    id,
    email,
    nome_completo,
    role,
    ativo,
    email_confirmado,
    created_at,
    updated_at
)
VALUES (
    uuid_generate_v4(),           -- Será gerado um UUID aleatório
    'admin@distribuidora.com',    -- ⚠️ ALTERE PARA SEU EMAIL
    'Administrador',               -- ⚠️ ALTERE O NOME SE DESEJAR
    'ADMIN'::user_role,
    true,
    true,
    NOW(),
    NOW()
)
ON CONFLICT (email) DO UPDATE
    SET role = 'ADMIN'::user_role,
        ativo = true,
        email_confirmado = true,
        updated_at = NOW();

-- Verificar inserção
SELECT id, email, nome_completo, role, ativo, email_confirmado 
FROM users 
WHERE email = 'admin@distribuidora.com';

-- ================================================================
-- ⚠️ SEQUÊNCIA CORRETA (REPITA PARA CADA NOVO USUÁRIO)
-- ================================================================

/*
CADA VEZ QUE QUISER CRIAR UM NOVO USUÁRIO:

┌─ PASSO 1: SUPABASE AUTH CONSOLE ─────────────────────────┐
│ 1. https://app.supabase.com/ → seu projeto               │
│ 2. Authentication → Users                                │
│ 3. "Create new user" (ou "Invite user")                  │
│ 4. Preencha:                                             │
│    Email: novo.usuario@distribuidora.com                │
│    Password: SenhaForte@123456   ← DEFINA AQUI!         │
│    Auto Confirm User: ☑️ (marque)                        │
│ 5. Clique em "Create user"                               │
│                                                         │
│ ✅ Usuário criado no Auth com a SENHA                   │
└──────────────────────────────────────────────────────────┘

┌─ PASSO 2: ESTE SCRIPT SQL ──────────────────────────────┐
│ 1. Copie o bloco INSERT abaixo                          │
│ 2. SQL Editor → Cole → Run                              │
│                                                         │
│ ✅ Usuário registrado na tabela users com ROLE          │
└──────────────────────────────────────────────────────────┘

┌─ PASSO 3: FAZER LOGIN ──────────────────────────────────┐
│ 1. Abra a página de login                               │
│ 2. Email: novo.usuario@distribuidora.com               │
│ 3. Senha: SenhaForte@123456 (do PASSO 1)               │
│                                                         │
│ ✅ Login bem-sucedido!                                  │
└──────────────────────────────────────────────────────────┘

NÃO PULE O PASSO 1!
Se pular e executar apenas o script SQL, o usuário NÃO conseguirá fazer login
porque não estará cadastrado no Supabase Auth.
*/

-- ================================================================
-- OUTROS USUÁRIOS INICIAIS RECOMENDADOS
-- ================================================================

/*
Após criar o admin, crie estes usuários com os mesmos passos:

1. GERENTE:
   Email: gerente@distribuidora.com
   Nome: Gerente Geral
   Role: GERENTE

2. OPERADOR DE CAIXA:
   Email: caixa@distribuidora.com
   Nome: Operador PDV 01
   Role: OPERADOR_CAIXA

3. ESTOQUISTA:
   Email: estoque@distribuidora.com
   Nome: Responsável Estoque
   Role: ESTOQUISTA

4. VENDEDOR:
   Email: vendedor@distribuidora.com
   Nome: Vendedor 01
   Role: VENDEDOR

Exemplo de inserção de múltiplos usuários:
*/

-- OPCIONAL: Inserir vários usuários de teste de uma vez
-- Descomente se quiser usar:

/*
INSERT INTO users (email, nome_completo, role, ativo, email_confirmado, created_at, updated_at)
VALUES
    ('gerente@distribuidora.com', 'Gerente Geral', 'GERENTE'::user_role, true, true, NOW(), NOW()),
    ('caixa@distribuidora.com', 'Operador PDV 01', 'OPERADOR_CAIXA'::user_role, true, true, NOW(), NOW()),
    ('estoque@distribuidora.com', 'Responsável Estoque', 'ESTOQUISTA'::user_role, true, true, NOW(), NOW()),
    ('vendedor@distribuidora.com', 'Vendedor 01', 'VENDEDOR'::user_role, true, true, NOW(), NOW()),
    ('comprador@distribuidora.com', 'Comprador', 'COMPRADOR'::user_role, true, true, NOW(), NOW())
ON CONFLICT (email) DO NOTHING;

-- Verificar todos os usuários criados:
SELECT email, nome_completo, role, ativo FROM users ORDER BY created_at DESC;
*/

-- ================================================================
-- GERENCIAMENTO DE PERMISSÕES POR ROLE
-- ================================================================

/*
Cada ROLE tem permissões diferentes no sistema:

┌──────────────────┬─────────────┬─────────┬────────┬────────────┬───────────┬──────────┐
│ Funcionalidade   │ ADMIN       │ GERENTE │ VENDEDOR │ OP. CAIXA │ ESTOQUISTA│ COMPRADOR│
├──────────────────┼─────────────┼─────────┼────────┼────────────┼───────────┼──────────┤
│ Dashboard        │ ✅ Completo │ ✅ View │ ✅ View │ ❌        │ ✅ View  │ ✅ View │
│ PDV/Vendas       │ ✅ Teste    │ ✅ View │ ✅ Criar│ ✅ FULL   │ ❌       │ ❌      │
│ Pre-Pedidos      │ ✅ FULL     │ ✅ FULL │ ✅ FULL │ ❌        │ ❌       │ ✅ FULL │
│ Estoque          │ ✅ FULL     │ ✅ FULL │ ❌     │ ❌        │ ✅ FULL  │ ❌      │
│ Clientes         │ ✅ FULL     │ ✅ FULL │ ✅ View │ ✅ View  │ ❌       │ ✅ FULL │
│ Fornecedores     │ ✅ FULL     │ ✅ View │ ❌     │ ❌        │ ❌       │ ✅ FULL │
│ Categorias/Marcas│ ✅ FULL     │ ✅ FULL │ ❌     │ ❌        │ ❌       │ ❌      │
│ Produtos         │ ✅ FULL     │ ✅ FULL │ ✅ View │ ✅ View  │ ✅ FULL  │ ❌      │
│ Usuários/RBAC    │ ✅ FULL     │ ❌     │ ❌     │ ❌        │ ❌       │ ❌      │
│ Configurações    │ ✅ FULL     │ ❌     │ ❌     │ ❌        │ ❌       │ ❌      │
│ Auditoria        │ ✅ FULL     │ ✅ View │ ❌     │ ❌        │ ❌       │ ❌      │
└──────────────────┴─────────────┴─────────┴────────┴────────────┴───────────┴──────────┘

ADMIN: Controle total + criação de usuários + configuração de sistema
GERENTE: Visão geral de tudo, autorização de ações críticas
VENDEDOR: Criar pedidos/vendas
OPERADOR_CAIXA: PDV completo (abrir/fechar caixa, receber pagamentos)
ESTOQUISTA: Controle de entrada/saída de estoque
COMPRADOR: Gerenciar fornecedores e pedidos de compra
APROVADOR: Autorizar transações e pedidos (se houver)
*/

-- ================================================================
-- COMANDOS ÚTEIS DE GERENCIAMENTO
-- ================================================================

-- Ver todos os usuários
-- SELECT id, email, nome_completo, role, ativo, last_login FROM users ORDER BY created_at DESC;

-- Desativar um usuário (sem deletar)
-- UPDATE users SET ativo = false WHERE email = 'usuario@email.com';

-- Reativar um usuário
-- UPDATE users SET ativo = true WHERE email = 'usuario@email.com';

-- Alterar role de um usuário
-- UPDATE users SET role = 'GERENTE'::user_role WHERE email = 'usuario@email.com';

-- Ver último login de um usuário
-- SELECT email, ultimo_login FROM users ORDER BY ultimo_login DESC NULLS LAST;

-- Ver auditoria de um usuário
-- SELECT usuario_id, acao, tabela, data_hora FROM auditoria_log WHERE usuario_id = '...uuid...' ORDER BY data_hora DESC LIMIT 50;

-- ================================================================
-- ⚠️ IMPORTANTE: CHECKLIST DE SEGURANÇA
-- ================================================================

/*
ANTES DE FAZER LOGIN:

[ ] Você criou o usuário no Supabase Auth (não apenas no SQL)?
[ ] O email está CONFIRMADO no Supabase Auth?
[ ] A senha é forte (mín 12 caracteres, maiúsculas, números, especiais)?
[ ] Você tem a credencial guardada em lugar seguro?
[ ] Você testou o login em ambiente de teste/homologação antes de produção?

APÓS PRIMEIRO LOGIN:

[ ] Crie um usuário GERENTE para organização
[ ] Configure a empresa em: Configurações → Dados da Empresa
[ ] Configure os dados fiscais (CNPJ, IE, Código IBGE, etc.)
[ ] Crie usuários para cada papel (OPERADOR_CAIXA, ESTOQUISTA, etc.)
[ ] Teste cada funcionalidade com o respectivo role
[ ] Configure backups automáticos
*/

-- ================================================================
-- ✅ PRONTO!
-- ================================================================

COMMIT;
