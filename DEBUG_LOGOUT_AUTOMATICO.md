# 🔍 Debug: Usuário Entra e Logo Faz Logout

## ⏪ O que está acontecendo

1. User faz login ✅
2. Entra no dashboard ✅
3. Sistema executa `checkAuth()` para validar dados
4. Um dos campos falha na validação ❌
5. User é desconectado automaticamente

---

## 🧪 Como Identificar o Problema

### Passo 1: Abra o Console do Navegador
1. Pressione `F12` (ou `Ctrl+Shift+I`)
2. Vá para a aba **Console**
3. Filtre por `❌` para ver os erros com ❌

### Passo 2: Faça Login Novamente
1. Acesse a página de login
2. Faça login com o usuário problemático
3. Observe o console enquanto ele entra e sai

### Passo 3: Procure por Mensagens de Erro

Você verá algo como:

```
❌ Email não confirmado. userData: { ativo: true, approved: true, email_confirmado: false }
```

ou

```
❌ Usuário não aprovado ou inativo. userData: { 
  ativo: false, 
  approved: true, 
  email_confirmado: true 
}
```

---

## 🛠️ Como Corrigir

### Se o erro for:
`❌ Email não confirmado`

**Solução:** Executar no Supabase SQL Editor:
```sql
UPDATE public.users
SET email_confirmado = true
WHERE email = 'user@example.com';
```

---

### Se o erro for:
`❌ Usuário não aprovado ou inativo`

**Solução:** Executar no Supabase SQL Editor:
```sql
UPDATE public.users
SET ativo = true, approved = true, approved_at = now()
WHERE email = 'user@example.com';
```

---

### Se o erro for:
`❌ ERRO ao verificar status do usuário`

**Solução:** Há um problema com RLS (Row Level Security):

1. Acesse: https://app.supabase.com
2. Vá em: **SQL Editor**
3. Execute este script:

```sql
-- Verificar RLS policies na tabela users
SELECT * FROM pg_policies WHERE tablename = 'users';

-- Se não houver policies, executar:
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuários autenticados leem users" ON users
FOR SELECT
USING (auth.uid() IS NOT NULL);

CREATE POLICY "Usuários autenticados atualizam users" ON users
FOR UPDATE
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Usuários inserem seu próprio perfil" ON users
FOR INSERT
WITH CHECK (id = auth.uid());
```

---

## 📊 Verificar Dados do Usuário

### Passo 1: Abra Supabase SQL Editor
https://app.supabase.com → SQL Editor

### Passo 2: Execute este query:

```sql
SELECT 
    id,
    email,
    nome_completo,
    role,
    ativo,
    email_confirmado,
    approved,
    approved_by,
    approved_at,
    created_at
FROM public.users
WHERE email = 'seu-email@example.com';
```

### Passo 3: Revise os valores

Devem ser:
- ✅ `ativo` = `true`
- ✅ `email_confirmado` = `true`
- ✅ `approved` = `true`

Se algum estiver `false`, é o culpado!

---

## 🚀 Solução Rápida

Se você quer que "aprovação automática" funcione, execute o script de fix:

```sql
UPDATE public.users
SET ativo = true, 
    approved = true, 
    email_confirmado = true,
    approved_at = now()
WHERE ativo IS NOT TRUE 
   OR approved IS NOT TRUE 
   OR email_confirmado IS NOT TRUE;
```

---

## 📝 Checklist de Debug

- [ ] Abri o console do navegador (F12)
- [ ] Fiz login novamente
- [ ] Anotei a mensagem de erro exata (copiar/colar)
- [ ] Executei o SQL de fix correspondente ao erro
- [ ] Fiz login novamente e testei
- [ ] Tudo funcionando! ✅

---

## 💡 Dicas

1. **Erro desaparece na tela mas vê no console?**
   - Abre console: F12
   - Procura por ❌
   - Copia a mensagem

2. **Vê "ERRO ao verificar status"?**
   - É provavelmente RLS (permissões)
   - Execute o script de RLS policies acima

3. **Usuário foi "aprovado" no painel mas ainda não passa?**
   - Os 3 campos DEVEM ser `true`:
     - `ativo`
     - `approved`
     - `email_confirmado`

---

## 🆘 Preciso de Ajuda

Se depois de executar tudo isso ainda não funcionar:

1. **Abra o Console (F12)** no navegador
2. **Copie a mensagem de erro** que aparece com ❌
3. **Compartilhe comigo** para diagnosticar

---

## 📚 Arquivo de Teste

Para verificar dados diretamente:
- Arquivo: `database/DEBUG_USUARIOS.sql`
- Copie e execute no Supabase SQL Editor
