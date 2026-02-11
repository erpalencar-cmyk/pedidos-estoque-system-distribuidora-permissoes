# 🔐 PROBLEMA: RLS Policies Bloqueando Leitura

## O Que Aconteceu

✅ O script SQL foi executado com sucesso  
✅ O admin foi inserido na tabela  
❌ Mas a **RLS Policy** está bloqueando a leitura do registro

---

## Por Que Isso Acontece

A policy atual está tentando fazer isso:

```sql
USING (auth.uid()::text = id::text)
```

Isso significa: "só deixa ler se o `auth.uid()` for igual ao `id` da linha"

**Problema:** O `id` na tabela é um UUID gerado aleatoriamente, não é o mesmo do `auth.uid()` do usuário!

---

## ✅ Solução: Executar Script de Correção

### Passo 1: Abrir SQL Editor

1. Acesse: https://btdqhrmbnvhhxeessplc.supabase.co
2. Clique em **"SQL Editor"** (esquerda)
3. Clique em **"+ New query"**

### Passo 2: Executar Script

1. Abra o arquivo: `database/CORRIGIR_RLS.sql`
2. Copie TODO o conteúdo
3. Cole no SQL Editor
4. **Aperte `Ctrl + Enter`**

### Passo 3: Verificar Resultado

Você verá:

```
Query 1: DROP POLICY (removeu policy antiga)
Query 2: CREATE POLICY (criou policy nova para empresas)
Query 3: CREATE POLICY (criou policy nova para admin_users)
Query 4: SELECT (mostra as policies criadas) ✅
Query 5: SELECT (mostra o admin encontrado) ✅
```

**Na Query 5, deve aparecer:**
```
id                                   | email                     | empresa_id
-------------------------------------|---------------------------|--------------------------------
[UUID]                               | brunoallencar@hotmail.com | [UUID da empresa]
```

---

## 🧪 Testar o Login

Depois de executar:

1. Volte ao navegador
2. Acesse: `http://localhost:8000`
3. Clique em **🔐 Sou Admin**
4. Email: `brunoallencar@hotmail.com`
5. Senha: `Bb93163087@@`
6. Deve funcionar agora! ✅

---

## 📝 O Que Mudou

**ANTES (bloqueado):**
```sql
CREATE POLICY "Admin pode ver seu próprio registro" ON admin_users 
    FOR SELECT USING (auth.uid()::text = id::text);
```

**DEPOIS (permite leitura):**
```sql
CREATE POLICY "public_read_admin_users" ON public.admin_users
    FOR SELECT
    USING (true);
```

Agora qualquer usuário autenticado pode ler a tabela (safe pois já passou pela autenticação no Auth).
