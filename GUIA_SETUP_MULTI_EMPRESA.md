# 🏪 Guia Setup - Sistema Multi-Empresa Centralizado

## **📋 Visão Geral da Arquitetura**

```
┌─────────────────────────────────────────┐
│   SUPABASE CENTRAL (Banco Master)      │
│   https://btdqhrmbnvhhxeessplc...      │
├─────────────────────────────────────────┤
│                                         │
│  Tabela: admin_users                    │
│  ├─ email: brunoallencar@hotmail.com   │
│  ├─ senha: Bb93163087@@                │
│  └─ empresa_id: [uuid]                 │
│                                         │
│  Tabela: empresas                       │
│  ├─ id, nome, cnpj                     │
│  ├─ supabase_url (banco da empresa)    │
│  └─ supabase_anon_key                  │
│                                         │
└─────────────────────────────────────────┘
         ↓
    ┌─────────────────────┐
    │  Sistema Web        │
    │  (seu projeto)      │
    └─────────────────────┘
         ↓
    ┌─────────────────────┐
    │ Quando admin login  │
    │ Carrega empresa     │
    │ e seu Supabase      │
    └─────────────────────┘
```

---

## **🚀 Passo 1: Criar Tabelas no Supabase Central**

1. Abra: https://btdqhrmbnvhhxeessplc.supabase.co
2. Vá para **SQL Editor**
3. Cole o conteúdo de: `database/setup-admin-central.sql`
4. Execute os comandos para criar tabelas

### **SQL a executar:**

```sql
-- Tabela de Empresas
CREATE TABLE IF NOT EXISTS empresas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    cnpj VARCHAR(20) NOT NULL UNIQUE,
    supabase_url TEXT NOT NULL,
    supabase_anon_key TEXT NOT NULL,
    logo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Admins
CREATE TABLE IF NOT EXISTS admin_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    empresa_id UUID NOT NULL REFERENCES empresas(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## **🔐 Passo 2: Criar usuário Admin no Supabase**

1. Vá para **Authentication > Users**
2. Clique em **Add User**
3. Preencha:
   - **Email:** `brunoallencar@hotmail.com`
   - **Password:** `Bb93163087@@`
4. Clique em **Send invite** ou **Create user**

---

## **🏢 Passo 3: Inserir Empresa e Vincular Admin**

Volte ao **SQL Editor** e execute:

```sql
-- 1. INSERIR EMPRESA (substitua os dados)
INSERT INTO empresas (nome, cnpj, supabase_url, supabase_anon_key)
VALUES (
    'Distribuidora Bruno Allencar',
    '12.345.678/0001-99',
    'https://uyyyxblwffzonczrtqjy.supabase.co',  -- Seu Supabase da empresa
    'sb_publishable_uGN5emN1tfqTgTudDZJM-g_Qc4YKIj_'  -- Sua anon key
);

-- 2. VINCULAR ADMIN À EMPRESA (copie o ID da empresa acima)
INSERT INTO admin_users (email, empresa_id)
SELECT 'brunoallencar@hotmail.com', id 
FROM empresas 
WHERE cnpj = '12.345.678/0001-99';

-- 3. VERIFICAR
SELECT * FROM empresas;
SELECT * FROM admin_users;
```

---

## **✅ Passo 4: Testar o Sistema**

### **A. Login de Cliente (usuário normal)**
1. Abra `index.html`
2. Teste com usuário de uma empresa

### **B. Login de Admin** 🔐
1. Clique em **"🔐 Sou Admin"** em `index.html`
2. Email: `brunoallencar@hotmail.com`
3. Senha: `Bb93163087@@`
4. Deve redirecionar para dashboard com dados da empresa

### **C. Cadastrar novo usuário**
1. Clique em **"Cadastre-se"** em `index.html`
2. Selecione a empresa (aparecerá "Distribuidora Bruno Allencar")
3. Preencha dados
4. Ao logar, sistema carrega Supabase da empresa selecionada

---

## **🔑 Fluxo de Login Detalhado**

### **Admin:**
```
1. Email: brunoallencar@hotmail.com
2. Senha: Bb93163087@@
   ↓
3. Autentica contra Supabase Central ✅
   ↓
4. Busca admin_users onde email = brunoallencar@hotmail.com
   ↓
5. Obtém empresa_id desse admin
   ↓
6. Carrega empresa em 'empresas' table
   ↓
7. Pega supabase_url e supabase_anon_key
   ↓
8. Inicializa novo cliente Supabase com essas credenciais ✅
   ↓
9. Redireciona para dashboard com empresa selecionada
```

### **Usuário Normal:**
```
1. Index.html pede email/senha
   ↓
2. Seleciona empresa (dropdown carregado de 'empresas')
   ↓
3. Carrega credenciais Supabase dessa empresa
   ↓
4. Cadastra usuário no Supabase da empresa ✅
   ↓
5. Login funciona contra Supabase correto
```

---

## **📝 Novas Empresas**

Para adicionar nova empresa, execute (no SQL Editor):

```sql
INSERT INTO empresas (nome, cnpj, supabase_url, supabase_anon_key)
VALUES (
    'Nome da Empresa',
    '99.999.999/0001-99',
    'https://nova-empresa.supabase.co',
    'sb_publishable_NOVA_KEY_AQUI'
);

-- Buscar o ID da empresa criada
SELECT id FROM empresas WHERE cnpj = '99.999.999/0001-99';

-- Vincular admin
INSERT INTO admin_users (email, empresa_id)
VALUES ('admin@novaempresa.com', 'COPIE_O_ID_ACIMA');
```

---

## **🔒 Segurança - IMPORTANTE!**

✅ **Credenciais Supabase das empresas armazenadas no banco central**
✅ **Admin validado no Supabase Central com autenticação real**
✅ **Cada empresa usa seu próprio Supabase após login**
✅ **Roles e RLS podem ser usados para mais segurança**

❌ **NÃO fazer commit de credenciais sensíveis** 
❌ **NÃO compartilhar senha do admin**
❌ **NÃO expor private keys ao frontend**

---

## **🐛 Troubleshooting**

| Erro | Solução |
|------|---------|
| "Empresa não encontrada" | Verificar se empresa está inserida em `empresas` |
| "Email não encontrado" | Admin deve estar em `admin_users` |
| "Erro ao carregar empresas" | Verificar RLS policies nas tabelas |
| "Supabase não inicializado" | Aguarde carregar config.js antes de usar |

---

## **📂 Arquivos Alterados**

- ✅ `index.html` - Adicionado botão "Sou Admin"
- ✅ `pages/admin-login.html` - Nova página de login admin
- ✅ `pages/register.html` - Seleção de empresa antes de cadastro
- ✅ `js/config.js` - Funções para carregar empresas e Supabase dinâmico
- ✅ `database/setup-admin-central.sql` - Scripts SQL para criar tabelas

---

**Pronto! Sistema multi-empresa centralizado ativado! 🚀**
