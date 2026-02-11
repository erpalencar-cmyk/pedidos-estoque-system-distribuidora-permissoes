# ✅ CHECKLIST - Setup Completo do Sistema

## **📋 Passos em Ordem:**

### **1️⃣ DIGITar SQL no Supabase Central** ⏱️ 5 min
```
Acesse: https://btdqhrmbnvhhxeessplc.supabase.co
│
├─ Clique em: SQL Editor (lateral esquerda)
├─ Copie TODO o conteúdo de: database/setup-admin-central.sql
├─ Cole no editor do Supabase
└─ Clique em RUN (executa todos os comandos)

✅ Resultado esperado: Tabelas criadas (empresas e admin_users)
```

---

### **2️⃣ Obter Admin Key** ⏱️ 3 min
```
No Supabase:
│
├─ Clique em: Settings (lateral esquerda)
├─ Clique em: API
├─ Procure por: "Service Role Key" (é uma chave com eyJ...)
├─ Clique em [Copy] para copiar
└─ NÃO FECHE ESSA PÁGINA (você vai precisar!)

✅ Resultado esperado: Chave copiada para clipboard
```

---

### **3️⃣ Colar Admin Key no .env** ⏱️ 1 min
```
No Visual Studio Code:
│
├─ Abra: scripts/.env
├─ Veja a linha: SUPABASE_ADMIN_KEY=COLE_AQUI_...
├─ Substitua COLE_AQUI_... pela chave que copiou no passo 2
├─ Salve o arquivo (Ctrl+S)
└─ Pronto!

Ficará assim:
SUPABASE_ADMIN_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc...
```

---

### **4️⃣ Rodar Script Python** ⏱️ 1 min
```
No Terminal do VS Code:
│
├─ Vá para pasta: cd scripts
├─ Execute: python setup-admin.py
└─ Aguarde a mensagem: ✅ SETUP CONCLUÍDO COM SUCESSO!

✅ O script vai criar:
   • Usuário auth (brunoallencar@hotmail.com / Bb93163087@@)
   • Registro na tabela empresas
   • Vínculo na tabela admin_users
```

---

## **🧪 TESTE AGORA**

### **Test 1: Admin Login**
```
1. Abra: http://localhost/index.html
2. Clique em: 🔐 Sou Admin
3. Preencha:
   Email: brunoallencar@hotmail.com
   Senha: Bb93163087@@
4. Clique em: Entrar

✅ Esperado: Redireciona para dashboard com empresa carregada
```

### **Test 2: Usuário Normal**
```
1. Abra: http://localhost/index.html
2. Clique em: Cadastre-se
3. Selecione empresa: "Distribuidora Bruno Allencar"
4. Preencha dados (email, senha, nome)
5. Clique em: Cadastrar
6. Confirme email (ou faça login se não precisar)

✅ Esperado: Usuário criado no Supabase da empresa selecionada
```

---

## **🔍 Se der ERRO:**

| Erro | Solução |
|------|---------|
| `❌ Invalid login credentials` | Admin não foi criado ou senha errada. Rode `python setup-admin.py` de novo |
| `❌ Dados do admin não encontrados` | Tabela `admin_users` vazia. Rode `python setup-admin.py` |
| `❌ Empresa não encontrada` | Tabela `empresas` vazia. Rode `python setup-admin.py` |
| `❌ Access to storage not allowed` | Erro de localStorage (browser sandbox). Admin-login.html já foi corrigido |
| `❌ Service Role Key inválida` | Copie de novo do Supabase (Settings > API > Service Role Key) |

---

## **📂 Arquivos Principais:**

```
projeto/
├── database/
│   └── setup-admin-central.sql    ← SQL para criar tabelas
│
├── scripts/
│   ├── setup-admin.py             ← Script que cria usuário e empresa
│   ├── requirements.txt            ← Dependências Python
│   ├── .env                        ← Sua Admin Key (⚠️ NUNCA commit!)
│   ├── .env.example               ← Template
│   └── OBTER_ADMIN_KEY.md          ← Guia para obter key
│
├── pages/
│   ├── admin-login.html            ← Login do admin
│   ├── register.html               ← Cadastro com seleção de empresa
│   └── dashboard.html              ← Dashboard (próxima página)
│
├── js/
│   └── config.js                   ← Carrega empresas e Supabase dinâmico
│
└── index.html                      ← Home com 2 botões (login normal + admin)
```

---

## **⏭️ Próxima Etapa (Depois que funcionar):**

- [ ] Rodar todos os testes acima
- [ ] Fazer commit no Git
- [ ] Adicionar mais empresas (executar INSERT na tabela `empresas`)
- [ ] Implementar dashboard/sistema

---

**Você consegue fazer todos esses passos? Ou quer que eu te ajude em algum?** 🚀
