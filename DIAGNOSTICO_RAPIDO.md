# 🔍 Diagnóstico Rápido - Admin Não Encontrado

## **Estado Atual:**

```
Auth (Autenticação)
├─ Email: brunoallencar@hotmail.com ✅
├─ Senha: Bb93163087@@ ✅
└─ Status: AUTENTICADO ✅

                    ↓ (Problema aqui!)

admin_users (Tabela do banco)
├─ Email esperado: brunoallencar@hotmail.com ❌
├─ Empresa: ??? ❌
└─ Status: NÃO ENCONTRADO ❌
```

---

## **Solução em 3 passos:**

### **1️⃣ Verifique os dados**

Abra Supabase > SQL Editor

Execute isto:
```sql
SELECT * FROM admin_users;
SELECT * FROM empresas;
```

Ver resultado em baixo da tela.

---

### **2️⃣ Se admin_users estiver VAZIO:**

Execute isto:
```sql
INSERT INTO admin_users (email, empresa_id)
SELECT 'brunoallencar@hotmail.com', id 
FROM empresas WHERE cnpj = '12.345.678/0001-99';
```

Clique: **RUN**

---

### **3️⃣ Teste de novo**

`index.html` → **🔐 Sou Admin** → Entre

---

## **✅ Leia também:**

Abra este arquivo para passo-a-passo completo:
**[ERRO_ADMIN_NAO_ENCONTRADO.md](ERRO_ADMIN_NAO_ENCONTRADO.md)**

---

**Consegue seguir esses passos agora?** 🚀
