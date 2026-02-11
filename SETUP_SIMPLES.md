# 🚀 SETUP RÁPIDO (SEM ERROS!)

## **Solução SIMPLES: Executar SQL Diretamente** ⏱️ 3 minutos

Esqueça o script Python. Vamos fazer direto pelo Supabase (mais fácil e seguro!)

---

## **PASSO 1: Abra o Supabase** 
Clique: https://btdqhrmbnvhhxeessplc.supabase.co

---

## **PASSO 2: Vá para SQL Editor**

```
Você está no dashboard do Supabase
│
├─ Lateral Esquerda → "SQL Editor"
└─ Clique lá
```

Deve aparecer uma tela branca com um editor de código.

---

## **PASSO 3: Copie TODO este SQL**

Abra este arquivo no VS Code:
```
database/SETUP_RAPIDO.sql
```

Selecione **TUDO** (Ctrl+A) e copie (Ctrl+C).

---

## **PASSO 4: Cole no Supabase**

No editor do Supabase (a telinha branca):
```
Clique no editor
Cole o SQL (Ctrl+V)
Você verá todo o código
```

Deve parecer assim:
```
CREATE TABLE IF NOT EXISTS empresas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ...
```

---

## **PASSO 5: Execute**

Procure pelo botão **RUN** (geralmente no canto direito ou superior).

```
┌──────────────────────────┐
│  SQL Editor              │
├──────────────────────────┤
│ CREATE TABLE IF NOT...   │
│                          │
│        [RUN] ← CLIQUE!   │
└──────────────────────────┘
```

---

## **PASSO 6: Aguarde**

Você verá mensagens como:
```
✅ CREATE TABLE "public"."empresas"
✅ CREATE TABLE "public"."admin_users"
✅ INSERT 1 row into "empresas"
✅ INSERT 1 row into "admin_users"
```

Se vir assim = **SUCESSO!** ✅

---

## **PASSO 7: Criar Usuário Admin no Auth**

⚠️ **MUITO IMPORTANTE:** Este passo é OBRIGATÓRIO!

O SQL criou os dados nas tabelas, mas o **usuário de login** precisa ser criado no Supabase Authentication.

Abra este guia COMPLETO COM FOTOS VISUAIS:
**→ [CRIAR_USUARIO_AUTH.md](CRIAR_USUARIO_AUTH.md)**

Ou siga os passos rápidos:

1. No Supabase: **Authentication > Users**
2. Clique: **"Create new user"**
3. Preencha:
   - Email: `brunoallencar@hotmail.com`
   - Senha: `Bb93163087@@`
   - ✅ Auto confirm user (MARCA ESTE BOX!)
4. Clique: **"Create user"**
5. Aguarde: `✅ User created successfully`

Pronto!

---

## **TESTE AGORA** 🧪

1. Abra seu projeto: `index.html`
2. Clique em **🔐 Sou Admin**
3. Preencha:
   - Email: `brunoallencar@hotmail.com`
   - Senha: `Bb93163087@@`
4. Clique em **Entrar**

---

## **Se der ERRO:**

| Erro | Solução |
|------|---------|
| `policy "Qualquer um pode ler empresas" already exists` | Tabelas já foram criadas! Continue para PASSO 7 |
| `"Invalid login credentials"` no login | ⚠️ Usuário NÃO foi criado no Auth! Abra [CRIAR_USUARIO_AUTH.md](CRIAR_USUARIO_AUTH.md) |
| `"User already exists"` ao criar no Auth | Usuário já foi criado, tente fazer login |
| `"Toast: Dados do admin não encontrados"` | SQL não foi executado. Execute [database/VERIFICAR_DADOS.sql](database/VERIFICAR_DADOS.sql) para verificar |
| `"Table empresas doesn't exist"` | Execute SETUP_RAPIDO.sql novamente |

---

## **✅ Checklist Final**

- [ ] Abri https://btdqhrmbnvhhxeessplc.supabase.co
- [ ] Copiei SQL de `database/SETUP_RAPIDO.sql`
- [ ] Colei e executei no SQL Editor
- [ ] Vi ✅ CREATE TABLE e ✅ INSERT
- [ ] Criei usuário em Authentication > Users
- [ ] Testei login com: `brunoallencar@hotmail.com` / `Bb93163087@@`
- [ ] Login funcionou! ✅

---

**Consegue fazer esses 7 passos agora?** 🚀
