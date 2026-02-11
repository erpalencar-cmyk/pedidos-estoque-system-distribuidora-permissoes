# 🔧 CORREÇÃO: Inserir Admin na Tabela

## Problema
O usuário `brunoallencar@hotmail.com` existe no Supabase Auth, mas **não existe na tabela `admin_users`** do banco central.

**Resultado:** Login falha com "❌ Nenhum admin encontrado"

---

## ✅ Solução: Executar 1 Script SQL

### Passo 1️⃣: Abrir SQL Editor do Supabase

1. Acesse: https://btdqhrmbnvhhxeessplc.supabase.co
2. No painel esquerdo, clique em **"SQL Editor"**
3. Clique em **"+ New query"**

### Passo 2️⃣: Copiar e Executar o Script

1. Abra o arquivo: `database/INSERIR_ADMIN.sql`
2. **Copie TODO o conteúdo** do arquivo
3. Cole no SQL Editor do Supabase (colinha vazia que ficou aberta)
4. **Aperte `Ctrl + Enter`** ou clique no botão **"Run"** (triângulo ▶️)

### Passo 3️⃣: Verificar Resultado

Você verá 3 queries executadas:

```
Query 1: INSERT 0 0  (ou INSERT 0 1) ← Empresa criada
Query 2: INSERT 0 0  (ou INSERT 0 1) ← Admin criado
Query 3: SELECT 1    ← Deve mostrar a empresa
Query 4: SELECT 1    ← Deve mostrar o admin
Query 5: SELECT 1    ← Deve mostrar brunoallencar@hotmail.com + empresa_id
```

### ✅ Esperado na Query 5:

```
email                    | empresa_id
-------------------------|----------------------------------
brunoallencar@hotmail.com| [UUID da empresa]
```

---

## 🧪 Testar o Login Depois

Após executar o script:

1. Volta ao navegador
2. Acesse: `http://localhost:8000` (ou seu servidor)
3. Clique em **🔐 Sou Admin**
4. Email: `brunoallencar@hotmail.com`
5. Senha: `Bb93163087@@`
6. **Deve aparecer: ✅ Bem-vindo Distribuidora Bruno Allencar!**

---

## ❓ Se Ainda Não Funcionar

Execute este SQL para **diagnosticar**:

```sql
-- Verificar se as tabelas existem
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name IN ('empresas', 'admin_users');

-- Contar registros
SELECT COUNT(*) as total_empresas FROM public.empresas;
SELECT COUNT(*) as total_admins FROM public.admin_users;

-- Ver todos os admins
SELECT email, empresa_id FROM public.admin_users;
```

Se as tabelas não aparecerem, execute primeiro: `database/SETUP_RAPIDO.sql`

