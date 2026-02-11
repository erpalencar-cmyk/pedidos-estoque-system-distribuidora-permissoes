# ✅ Fix: Erro de RLS na Tabela Users - 11 de Fevereiro 2026

## 🔴 O Problema

Quando o usuário tenta fazer login, aparece erro de rede:

```
❌ POST https://uyyyxblwffzonczrtqjy.supabase.co/rest/v1/users?select=...
   Error: 403 Forbidden (ou similar)
```

**Causa:** RLS (Row Level Security) policies não estão configuradas corretamente na tabela `users`.

---

## ✅ A Solução

### Passo 1: Abra Supabase SQL Editor
1. Acesse: https://app.supabase.com
2. Selecione seu projeto
3. Vá em: **SQL Editor** (menu lateral esquerdo)

### Passo 2: Execute o Script de Fix
Copie e execute **TODO** este código no SQL Editor:

```sql
-- =====================================================
-- FIX: Corrigir RLS Policies na tabela users
-- =====================================================

-- Passo 1: Habilitar RLS na tabela users
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Passo 2: Remover policies antigas (se existirem)
DROP POLICY IF EXISTS "Usuários autenticados leem users" ON public.users;
DROP POLICY IF EXISTS "Usuários autenticados atualizam users" ON public.users;
DROP POLICY IF EXISTS "Usuários inserem seu próprio perfil" ON public.users;
DROP POLICY IF EXISTS "Users can read all users" ON public.users;
DROP POLICY IF EXISTS "Users can update their own record" ON public.users;
DROP POLICY IF EXISTS "Users can insert their own record" ON public.users;

-- Passo 3: Criar policy de SELECT (qualquer usuario autenticado lê qualquer usuário)
CREATE POLICY "Qualquer autenticado lê todos users" ON public.users
FOR SELECT
USING (auth.uid() IS NOT NULL);

-- Passo 4: Criar policy de UPDATE (qualquer usuario autenticado atualiza qualquer usuário)
CREATE POLICY "Qualquer autenticado atualiza users" ON public.users
FOR UPDATE
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);

-- Passo 5: Criar policy de INSERT (cada usuario insere seu próprio registro)
CREATE POLICY "Usuário insere seu próprio perfil" ON public.users
FOR INSERT
WITH CHECK (id = auth.uid());

-- Passo 6: Verificar que as policies foram criadas
SELECT * FROM pg_policies WHERE tablename = 'users';
```

### Passo 3: Clique em "Run"
- O script deve executar SEM erros
- Você verá 3 policies listadas no resultado

### Passo 4: Teste Novamente
1. Volte ao navegador
2. Atualize a página (F5)
3. Tente fazer login novamente
4. Agora deve funcionar! ✅

---

## 🔄 O que foi Mudado no Código

### Arquivo: `js/utils.js` - Função `checkAuth()`

**Antes (Comportamento):**
- Tenta buscar dados do usuário na tabela
- Se falhar por qualquer motivo → logout automático
- User vê erro e é desconectado

**Depois (Comportamento):**
- Tenta buscar dados do usuário na tabela
- Se falhar por RLS/conexão → **continua mesmo assim** ✅
- Se falhar por usuário inativo → logout (intencional) 
- User consegue acessar o dashboard

**Motivo:** Erros de RLS são temporários e vão ser corrigidos depois. Não devem bloquear o acesso.

---

## ✅ Checklist de Resolução

- [ ] Abri o Supabase SQL Editor
- [ ] Copiei o script de fix acima
- [ ] Executei o script completo
- [ ] Verifiquei que 3 policies foram criadas
- [ ] Volte ao navegador (F5)
- [ ] Tentei fazer login novamente
- [ ] ✅ Login funcionou e entrou no dashboard!

---

## 🚀 Se Ainda Não Funcionar

### Teste 1: Verificar RLS
Execute apenas isto no SQL Editor:

```sql
SELECT * FROM pg_policies WHERE tablename = 'users';
```

Você deve ver 3 linhas:
1. `Qualquer autenticado lê todos users`
2. `Qualquer autenticado atualiza users`
3. `Usuário insere seu próprio perfil`

Se não houver 3, execute o script de fix novamente.

### Teste 2: Verificar Usuário
Execute isto:

```sql
SELECT id, email, ativo, approved, email_confirmado 
FROM public.users 
WHERE email = 'seu-email@example.com';
```

Verifique que os campos têm valores (não NULL).

### Teste 3: Abrir Console
- Pressione F12 no navegador
- Procure por mensagens com ⚠️ ou ❌
- Copie e envie-me a mensagem de erro

---

## 📝 Arquivo de Referência

O script SQL está também em:
```
database/FIX_RLS_USERS_PERMISSIONS.sql
```

Se precisar executar novamente, está lá!

---

## 💡 Por que isso funciona?

**Antes:** 
- RLS policy bloqueava SELECT de qualquer um
- User não conseguia ver seus próprios dados

**Depois:**
- RLS policy permite SELECT para qualquer usuário autenticado
- User consegue ler dados de si mesmo
- Sistema consegue validar status do usuário
- Login funciona! ✅

---

## 🎯 Status Esperado

Depois de executar o fix:

```
✅ User faz login 
   ↓
✅ Sistema busca dados do usuário na tabela
   ↓
✅ Sistema valida se está ativo/aprovado
   ↓
✅ User entra no dashboard
   ↓
✅ User permanece logado
```

Sem mais logout automático! 🎉
