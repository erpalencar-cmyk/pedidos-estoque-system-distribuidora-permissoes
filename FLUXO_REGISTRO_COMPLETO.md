# 🔐 Fluxo Completo de Registro e Aprovação de Usuários

## Visão Geral

O sistema implementa um fluxo de 3 etapas para validação de novos usuários:

```
REGISTRO → EMAIL CONFIRMADO → APROVAÇÃO ADMIN → ACESSO LIBERADO
```

---

## 1️⃣ Etapa 1: Registro (Register)

### Arquivo: `pages/register.html` + `js/auth.js`

**O que acontece:**
1. Usuário preenche formulário com:
   - Email
   - Senha
   - Nome completo
   - Role (tipo de cargo)
   - WhatsApp (opcional)

2. Função `register()` em `js/auth.js` é acionada:
   - Cria usuário em **Supabase Auth** (sem confirmação de email ainda)
   - Insere registro em tabela **users** com status:
     - `ativo: false` ❌ (bloqueado de fazer login)
     - `email_confirmado: false` ❌ (não confirmou email)
     - `approved: false` ❌ (aguardando aprovação admin)

```javascript
// js/auth.js - função register (linhas 38-108)
const { error: userError } = await window.supabase
    .from('users')
    .insert([{
        id: authData.user.id,
        email: email,
        full_name: fullName,
        nome_completo: fullName,
        role: role,
        whatsapp: whatsapp,
        ativo: false,              // ← Bloqueado
        email_confirmado: false,   // ← Aguardando confirmação
        approved: false            // ← Aguardando aprovação
    }]);
```

**Resultado:**
- ✅ Usuário criado em Auth
- ✅ Registro criado em database
- 📧 Supabase envia email de confirmação automaticamente
- ❌ Usuário NÃO pode fazer login ainda

---

## 2️⃣ Etapa 2: Confirmação de Email

### Arquivo: `js/auth.js` (função `syncEmailConfirmationStatus`)

**O que acontece:**

**Quando usuário clica no link do email:**
1. Supabase Auth automáticamente marca `email_confirmed_at` como timestamp
2. Email é confirmado no **Auth**, mas a tabela **users** ainda tem `email_confirmado: false`

**Quando usuário tenta fazer login:**
1. Função `login()` em `js/auth.js`:
   - Verifica `data.user.email_confirmed_at` no Auth
   - Se email FOI confirmado, chama `syncEmailConfirmationStatus(userId)`

2. Função `syncEmailConfirmationStatus()` atualiza banco:
   ```javascript
   // js/auth.js - função syncEmailConfirmationStatus (linhas 269-282)
   await window.supabase
       .from('users')
       .update({ email_confirmado: true })
       .eq('id', userId)
       .eq('email_confirmado', false);  // Só atualiza se ainda não estava confirmado
   ```

**Status após confirmação:**
- ✅ Email confirmado em Auth
- ✅ `email_confirmado: true` no banco
- ❌ `approved: false` (ainda aguardando admin)
- ❌ `ativo: false` (ainda bloqueado)

---

## 3️⃣ Etapa 3: Proteção de Acesso

### Arquivo: `js/utils.js` (função `protectPageAccess`)

**O que acontece quando usuário tenta acessar qualquer página protegida:**

1. **Primeira verificação** (linhas 196-205):
   ```javascript
   if (!userData || !userData.email_confirmado) {
       // Logout e mostra mensagem
       showToast('⏳ Você precisa confirmar seu email...', 'warning');
   }
   ```
   - **Rejeita:** usuários que não confirmaram email
   - **Mensagem:** "Você precisa confirmar seu email"

2. **Segunda verificação** (linhas 207-218):
   ```javascript
   if (!userData || !userData.ativo || !userData.approved) {
       // Logout e mostra mensagem
       showToast('⏳ Sua conta está aguardando aprovação do administrador...', 'warning');
   }
   ```
   - **Rejeita:** usuários que não foram aprovados
   - **Rejeita:** usuários desativados
   - **Mensagem:** "Sua conta está aguardando aprovação do administrador"

**Lógica de acesso:**
```
email_confirmado = true  ✓
approved = true          ✓
ativo = true             ✓
                        ↓
    ACESSO LIBERADO ✅
```

---

## 4️⃣ Etapa 4: Aprovação de Admin

### Arquivo: `pages/aprovacao-usuarios.html`

**Quem acessa:** Usuários com role `ADMIN`

**URL:** `/pages/aprovacao-usuarios.html`

### Tela de Pendentes

**Mostra usuários que:**
- Confirmaram email (`email_confirmado: true`)
- Mas NÃO foram aprovados (`approved: false`)

```javascript
// pages/aprovacao-usuarios.html - função loadUsuarios (linhas 207-209)
const pendentes = usuarios.filter(u => u.email_confirmado && !u.approved);
```

**Ações disponíveis:**
1. **✅ Aprovar** - Executa `confirmarAprovacao()`
2. **❌ Rejeitar** - Executa `confirmarRejeicao()`

### Função: Aprovar Usuário

```javascript
// pages/aprovacao-usuarios.html - função confirmarAprovacao (linhas 301-325)
await window.supabase
    .from('users')
    .update({ 
        ativo: true,              // ← Libera acesso
        approved: true,           // ← Marca como aprovado
        approved_by: adminId,     // ← Registra quem aprovou
        approved_at: timestamp    // ← Momento da aprovação
    })
    .eq('id', usuarioSelecionado);

// Envia email de notificação
await enviarEmailAprovacao(email, nome);
```

**Resultado:**
- ✅ `ativo: true` - Acesso liberado
- ✅ `approved: true` - Marca aprovação
- ✅ Admin e timestamp registrados
- 📧 Email enviado ao usuário

### Tela de Aprovados

**Mostra usuários que:**
- Foram aprovados (`approved: true`)
- Estão ativos (`ativo: true`)

```javascript
// pages/aprovacao-usuarios.html - função loadUsuarios (linhas 211-213)
const aprovados = usuarios.filter(u => u.approved && u.ativo);
```

**Ações disponíveis:**
1. **🔒 Desativar** - Executa `desativarUsuario()`

### Função: Desativar Usuário

```javascript
// pages/aprovacao-usuarios.html - função desativarUsuario (linhas 382-401)
await window.supabase
    .from('users')
    .update({ 
        ativo: false,             // ← Bloqueia acesso
        approved: false           // ← Marca como não aprovado
    })
    .eq('id', id);
```

---

## 📊 Tabela de Estados

| Estado | email_confirmado | approved | ativo | Pode Login? | Mensagem |
|--------|-----------------|----------|-------|------------|----------|
| Registrado | ❌ | ❌ | ❌ | ❌ | Confirme seu email |
| Email Confirmado | ✅ | ❌ | ❌ | ❌ | Aguardando aprovação |
| Aprovado | ✅ | ✅ | ✅ | ✅ | Bem-vindo! |
| Desativado | ✅ | ❌ | ❌ | ❌ | Aguardando aprovação |

---

## 🔄 Fluxo Passo a Passo (Usuário Final)

### Passo 1: Registro
```
1. Acessa https://seu-site.com/pages/register.html
2. Preenche formulário
3. Clica em "Cadastrar"
4. Vê mensagem: "Verifique seu email para confirmar!"
```

### Passo 2: Confirmação de Email
```
1. Abre email de confirmação
2. Clica no link "Confirmar Email"
3. Supabase redireciona para login
4. Tenta fazer login
5. Sistema sincroniza email_confirmado = true
```

### Passo 3: Aguardando Aprovação
```
1. Faz login com sucesso
2. Sistema verifica approved = false
3. É redirecionado para index.html
4. Vê mensagem: "Sua conta está aguardando aprovação"
5. Aguarda admin aprovar
```

### Passo 4: Admin Aprova
```
1. Admin acessa /pages/aprovacao-usuarios.html
2. Clica em "✅ Aprovar" no usuário aguardando
3. Sistema atualiza: ativo = true, approved = true
4. User recebe email: "Sua conta foi aprovada!"
5. User faz login e acessa sistema
```

---

## 🛡️ Segurança

### Proteções Implementadas:

1. **Email Obrigatório**
   - Usuário DEVE confirmar email antes de usar sistema

2. **Aprovação Admin Obrigatória**
   - Novo usuário SEMPRE necessita aprovação manual
   - Impede uso por usuários não autorizados

3. **Bloqueio Duplo**
   - `email_confirmado` AND `approved` AND `ativo` devem ser TRUE
   - Se admin desativa, ambos campos são resetados

4. **Rastreabilidade**
   - `approved_by` registra qual admin aprovou
   - `approved_at` registra quando foi aprovado

5. **Sincronização**
   - Sistema verifica Auth + Database
   - Email confirmado em Auth é sincronizado para Database

---

## 🐛 Troubleshooting

### Problema: User registrado mas não aparece em pendentes

**Causas possíveis:**
1. Email confirmado mas `email_confirmado` no banco ainda é false
   - **Solução:** User faz login uma vez (isso sincroniza)

2. Usuário nunca confirmou email
   - **Solução:** Verificar se email foi recebido, pedir para confirmar

3. `approved` field não foi criado no banco
   - **Solução:** Executar migration para adicionar campo

### Problema: Usuário não consegue fazer login após aprovação

**Causas possíveis:**
1. Campo `approved` não foi atualizado no banco
   - **Solução:** Verificar logs em `/pages/aprovacao-usuarios.html`

2. Sessão cacheada no navegador
   - **Solução:** User fazer logout/login novamente

3. Middleware de proteção está rejeitando mesmo após aprovação
   - **Solução:** Verificar `protectPageAccess()` em utils.js

---

## 📝 Resumo de Arquivo Modificados

| Arquivo | Função | Mudança |
|---------|--------|---------|
| `js/auth.js` | `register()` | Insere em users com status false |
| `js/auth.js` | `login()` | Chama `syncEmailConfirmationStatus()` |
| `js/auth.js` | `syncEmailConfirmationStatus()` | Nova função para sincronizar confirmação |
| `js/utils.js` | `protectPageAccess()` | Valida email_confirmado + approved |
| `pages/aprovacao-usuarios.html` | `loadUsuarios()` | Filtra por email_confirmado + approved |
| `pages/aprovacao-usuarios.html` | `confirmarAprovacao()` | Seta approved=true + ativo=true |
| `pages/aprovacao-usuarios.html` | `desativarUsuario()` | Seta approved=false + ativo=false |

---

## ✅ Checklist de Implementação

- [x] `register()` cria usuário com status inicial false
- [x] `syncEmailConfirmationStatus()` sincroniza confirmação
- [x] `login()` chama sync de email confirmado
- [x] `protectPageAccess()` verifica email_confirmado
- [x] `protectPageAccess()` verifica approved
- [x] `loadUsuarios()` filtra correto (email_confirmado + não approved)
- [x] `confirmarAprovacao()` seta approved=true + ativo=true
- [x] `desativarUsuario()` seta approved=false + ativo=false
- [ ] **TESTA:** User registra → confirma email → aguarda aprovação → admin aprova → user acessa

---

## 📞 Próximos Passos

1. **Testar fluxo completo:**
   - Registrar novo usuário
   - Confirmar email
   - Tentar login (deve aparecer mensagem de aguardando aprovação)
   - Admin aprova
   - User consegue fazer login

2. **Verificar migrations:**
   - Campos `email_confirmado`, `approved`, `approved_by`, `approved_at` existem?

3. **Melhorias futuras:**
   - Enviar email para admin quando novo user registra
   - Dashboard com resumo de pendentes
   - Logs de quem aprovou quem e quando
