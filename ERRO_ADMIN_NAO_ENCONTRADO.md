# ❌ Erro: "Admin não encontrado na tabela admin_users"

## **O que aconteceu:**

```
✅ Usuário foi autenticado no Auth (OK!)
❌ Mas não foi encontrado na tabela admin_users
```

---

## **Possíveis causas:**

1. ❌ SQL `SETUP_RAPIDO.sql` não foi executado
2. ❌ O email criado no Auth está diferente de `brunoallencar@hotmail.com`
3. ❌ Tabela `admin_users` está vazia

---

## **SOLUÇÃO RÁPIDA:**

### **Passo 1: Verificar dados no banco**

Abra: https://btdqhrmbnvhhxeessplc.supabase.co

Vá para: **SQL Editor**

Cole isto:
```sql
-- Ver o que tem na tabela empresas
SELECT id, nome, cnpj FROM empresas;

-- Ver o que tem na tabela admin_users
SELECT email, empresa_id FROM admin_users;
```

Clique: **RUN**

---

### **Passo 2: Interpretar o resultado**

#### **Se aparecer:**
```
Empresas: 1 linha (Distribuidora Bruno Allencar)
Admins: 1 linha (brunoallencar@hotmail.com)
```
→ Dados estão ok! Problema está em outro lugar.

#### **Se `admin_users` estiver VAZIO:**
Vá para o **Passo 3**.

---

### **Passo 3: Inserir o admin manualmente**

Se a tabela `admin_users` estiver vazia, execute isto:

```sql
-- Primeiro, certifique-se que a empresa existe
INSERT INTO empresas (nome, cnpj, supabase_url, supabase_anon_key)
VALUES (
    'Distribuidora Bruno Allencar',
    '12.345.678/0001-99',
    'https://uyyyxblwffzonczrtqjy.supabase.co',
    'sb_publishable_uGN5emN1tfqTgTudDZJM-g_Qc4YKIj_'
)
ON CONFLICT (cnpj) DO NOTHING;

-- Depois, vincule o admin à empresa
INSERT INTO admin_users (email, empresa_id)
SELECT 
    'brunoallencar@hotmail.com',
    id 
FROM empresas 
WHERE cnpj = '12.345.678/0001-99'
ON CONFLICT (email) DO NOTHING;

-- Verifique se funcionou
SELECT * FROM admin_users;
```

Clique: **RUN**

---

### **Passo 4: Teste de novo**

1. Volte ao seu projeto: `index.html`
2. Clique: **🔐 Sou Admin**
3. Email: `brunoallencar@hotmail.com`
4. Senha: `Bb93163087@@`
5. Clique: **Entrar**

Deve funcionar agora! ✅

---

## **⚠️ SE O EMAIL ESTIVER DIFERENTE:**

Se você criou o usuário Auth com email diferente (ex: `bruno@gmail.com`), faça isto:

**Opção A: Apagar e recriar o usuário no Auth**
1. Authentication > Users
2. Procure o usuário
3. Clique em "..." > Delete user
4. Crie novamente com email: `brunoallencar@hotmail.com`

**Opção B: Atualizar a tabela admin_users**
Se não quiser deletar, execute isto no SQL:

```sql
DELETE FROM admin_users WHERE email = 'brunoallencar@hotmail.com';

INSERT INTO admin_users (email, empresa_id)
SELECT 
    'bruno@gmail.com',  -- Use o email que você usou no Auth
    id 
FROM empresas 
WHERE cnpj = '12.345.678/0001-99';
```

---

## **✅ Checklist:**

- [ ] Executei SQL de verificação
- [ ] Vi dados em `empresas` e `admin_users`
- [ ] Se vazio, executei SQL de inserção
- [ ] Testei login novamente
- [ ] Funcionou! ✅

---

**Consegue fazer esses passos?** 🚀
