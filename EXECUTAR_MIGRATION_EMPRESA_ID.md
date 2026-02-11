# 🔧 Executação de Migration: Adicionar empresa_id na tabela users

## 📋 Status

O registro agora funciona, mas com uma limitação temporária:
- ❌ Campo `empresa_id` está **comentado** em `js/auth.js`
- ⏳ Aguardando execução da migration no banco de dados

## 📝 Passos para Executar a Migration

### 1. Abra o Supabase Console
Acesse: https://app.supabase.com/

### 2. Selecione seu Projeto
Escolha: `pedidos-estoque-system-distribuidora-permissoes` (ou similar)

### 3. Acesse o SQL Editor
No menu lateral esquerdo, clique em **SQL Editor**

### 4. Execute a Migration
Copie e execute este código no SQL Editor:

```sql
-- Migration: Adicionar coluna empresa_id na tabela users
-- Description: Permite rastrear qual empresa um usuário foi registrado

ALTER TABLE public.users
ADD COLUMN empresa_id uuid NULL;

-- Criar índice para melhorar performance de queries
CREATE INDEX idx_users_empresa_id ON public.users USING btree (empresa_id);

-- Adicionar comentário na coluna
COMMENT ON COLUMN public.users.empresa_id IS 'ID da empresa a qual o usuário está vinculado';
```

Clique em **Run** para executar.

### 5. Descomente o Código em js/auth.js

Após executar a migration com sucesso:

**Arquivo:** `js/auth.js` (Linhas 60-73)

```javascript
// Antes (comentado)
/*
empresa_id: empresaId
*/

// Depois (descomentado)
empresa_id: empresaId
```

Ou procure por esta linha em `js/auth.js`:
```javascript
// empresa_id: empresaId  // ← Descomentar após executar migration add-empresa-id-users.sql
```

E mude para:
```javascript
empresa_id: empresaId
```

### 6. Recarregue o Navegador
Pressione `F5` ou `Ctrl+R` para recarregar a página e testar o registro novamente.

---

## ✅ Verificação

Após descommentar, o registro deve:
1. ✅ Criar usuário em Supabase Auth
2. ✅ Inserir registro em tabela `users` com `empresa_id` preenchido
3. ✅ Mostrar modal de confirmação de email
4. ✅ Usuário aparece em `/pages/aprovacao-usuarios.html` como pendente

---

## 📝 Arquivo da Migration

Localização: `database/migrations/add-empresa-id-users.sql`

Este arquivo será útil se precisar recriar o banco de dados do zero no futuro.

---

## 🆘 Se Receber Erro

### Erro: "Coluna já existe"
```
ERROR: column "empresa_id" of relation "users" already exists
```
**Solução:** A coluna já foi adicionada. Pule o passo 4 e vá direto para o passo 5.

### Erro: "Permission denied"
```
ERROR: permission denied for schema public
```
**Solução:** Você não tem permissão. Solicite ao administrador do Supabase para executar a migration.

### Erro em js/auth.js: "Could not find the 'empresa_id' column"
```
Could not find the 'empresa_id' column of 'users' in the schema cache
```
**Solução:** Você descomentou antes de executar a migration. Comente novamente em `js/auth.js` e execute a migration primeiro.

---

## 📊 Timeline Esperado

| Etapa | Status | Prazo |
|-------|--------|-------|
| Migration na DB | ⏳ Pendente | Imediato |
| Descomenta código JS | ⏳ Pendente | Após migration |
| Teste de registro | ⏳ Pendente | Após descomentar |
| Deploy completo | ⏳ Pendente | Após tudo OK |

---

## 💾 Próximos Passos

1. ✅ Executar migration no Supabase (SQL Editor)
2. ✅ Descommentar `empresa_id` em `js/auth.js`
3. ✅ Testar registro completo
4. ✅ Verificar se usuário novo tem `empresa_id` preenchido
