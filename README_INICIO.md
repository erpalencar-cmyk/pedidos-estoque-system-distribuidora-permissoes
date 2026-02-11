# 🎯 COMEÇAR AQUI - Guia Completo em 3 Passos

## **OPÇÃO 1: Rápido (3 min) ⚡**

Abra: [SETUP_SIMPLES.md](SETUP_SIMPLES.md)

Siga os 7 passos visuais. Pronto!

---

## **OPÇÃO 2: Detalhado (5 min) 📚**

Se preferir mais explicações, abra: [GUIA_SETUP_MULTI_EMPRESA.md](GUIA_SETUP_MULTI_EMPRESA.md)

---

## **🚀 TL;DR (Para os apressados):**

```bash
# 1. Abra Supabase
https://btdqhrmbnvhhxeessplc.supabase.co

# 2. Vá para SQL Editor e cole TUDO isto:
database/SETUP_RAPIDO.sql

# 3. Clique RUN

# 4. Vá para Authentication > Users
# Crie usuário: brunoallencar@hotmail.com / Bb93163087@@

# 5. Teste em index.html > 🔐 Sou Admin

# Pronto!
```

---

## **📂 Estrutura do Projeto:**

```
projeto/
│
├── index.html                    ← Home (Login + Botão Admin)
│
├── pages/
│   ├── admin-login.html         ← Login do Admin 🔐
│   ├── register.html            ← Cadastro (com seleção de empresa)
│   └── dashboard.html           ← Sistema (próxima página)
│
├── js/
│   └── config.js               ← Carrega empresa e Supabase dinâmico
│
├── database/
│   ├── SETUP_RAPIDO.sql         ← SQL pronto para colar no Supabase
│   └── setup-admin-central.sql  ← SQL completo (opcional)
│
├── SETUP_SIMPLES.md             ← 📖 Guia passo a passo visual
├── GUIA_SETUP_MULTI_EMPRESA.md  ← 📖 Guia detalhado
└── CHECKLIST_SETUP.md           ← 📋 Checklist completo
```

---

## **🎓 Como funciona:**

### **Sem Admin:**
```
Usuário abre index.html
    ↓
Clica "Cadastre-se"
    ↓
Seleciona empresa
    ↓
Cadastra Email/Senha
    ↓
Usa Supabase daquela empresa ✅
```

### **Com Admin:**
```
Admin abre index.html
    ↓
Clica "🔐 Sou Admin"
    ↓
Email: brunoallencar@hotmail.com ← Criado no Auth
Senha: Bb93163087@@
    ↓
Sistema busca empresa do admin
    ↓
Carrega Supabase dessa empresa ✅
    ↓
Vai para dashboard
```

---

## **🔑 Credenciais de Teste:**

```
Email:    brunoallencar@hotmail.com
Senha:    Bb93163087@@
Empresa:  Distribuidora Bruno Allencar
CNPJ:     12.345.678/0001-99
```

---

## **❓ Dúvidas?**

Leia os `.md` na ordem:
1. [SETUP_SIMPLES.md](SETUP_SIMPLES.md) ← Comece aqui!
2. [GUIA_SETUP_MULTI_EMPRESA.md](GUIA_SETUP_MULTI_EMPRESA.md) 
3. [CHECKLIST_SETUP.md](CHECKLIST_SETUP.md)

---

**Pronto para setup? Vá para [SETUP_SIMPLES.md](SETUP_SIMPLES.md)** 🚀
