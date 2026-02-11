# 🔐 Criar Usuário no Supabase Authentication

O erro `"Invalid login credentials"` significa que o usuário **NÃO FOI CRIADO** no Supabase Authentication.

SQL cria dados nas tabelas, mas **não cria usuário no Auth**. Temos que fazer isso manualmente!

---

## **PASSO 1: Abra o Supabase**

Link: https://btdqhrmbnvhhxeessplc.supabase.co

---

## **PASSO 2: Vá para Authentication**

```
Lateral esquerda → Clique em "Authentication"
                 → Clique em "Users"
```

Deve aparecer uma tela com usuários cadastrados (provavelmente vazia).

---

## **PASSO 3: Clique em "Create new user"**

Procure pelo botão:
```
┌────────────────────────────┐
│  User Management           │
├────────────────────────────┤
│                            │
│    [Create new user] ← AQUI│
│                            │
└────────────────────────────┘
```

---

## **PASSO 4: Preencha os dados EXATAMENTE assim:**

```
┌─────────────────────────────────────────┐
│  Create new user                        │
├─────────────────────────────────────────┤
│                                         │
│  Email: brunoallencar@hotmail.com       │
│  Password: Bb93163087@@                 │
│                                         │
│  ✅ Auto confirm user                  │
│     (MARCA ESTE CHECKBOX!)              │
│                                         │
│  [Create user]                          │
│                                         │
└─────────────────────────────────────────┘
```

---

## **PASSO 5: Clique em "Create user"**

Aguarde... você verá uma mensagem:
```
✅ User created successfully
```

---

## **PASSO 6: Volte e Teste**

1. Abra seu projeto: `index.html`
2. Clique em: **🔐 Sou Admin**
3. Preencha:
   ```
   Email: brunoallencar@hotmail.com
   Senha: Bb93163087@@
   ```
4. Clique em: **Entrar**

---

## **✅ Se funcionar:**
Você vai direto para o dashboard da empresa! 🎉

---

## **❌ Se der erro outro erro:**

| Erro | Causa | Solução |
|------|-------|---------|
| `"User already exists"` | Usuário já foi criado | Ignore e tente fazer login |
| `"Invalid email"` | Email inválido | Use exatamente: `brunoallencar@hotmail.com` |
| `"Password too short"` | Senha < 6 caracteres | Use: `Bb93163087@@` (11 caracteres) |
| `"Credenciais inválidas"` no login | Usuário não foi criado | Volte aqui e crie |

---

## **⚠️ IMPORTANTE:**

- ✅ Email deve ser **EXATO**: `brunoallencar@hotmail.com`
- ✅ Senha deve ser **EXATA**: `Bb93163087@@`
- ✅ Check **"Auto confirm user"** é obrigatório
- ❌ Não deixe campos em branco

---

**Consegue criar agora?** 🚀
