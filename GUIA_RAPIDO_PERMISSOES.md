# 🚀 Guia Rápido - Sistema de Permissões

## ⚡ 3 Passos para Começar

### 1️⃣ Executar Script SQL (2 minutos)

```
1. Abra https://app.supabase.com
2. Clique em seu projeto
3. Clique em "SQL Editor" → "New Query"
4. Abra: database/criar-sistema-permissoes.sql
5. Copie TODO o conteúdo
6. Cole na caixa do SQL Editor
7. Clique "Run" (verde, canto superior)
8. Aguarde: "Success. 227 rows affected"
```

**✅ Pronto!** As 5 tabelas foram criadas com dados iniciais.

---

### 2️⃣ Acessar Interface de Admin (1 minuto)

```
1. Acesse: http://localhost:8000/admin-painel.html
2. Clique em: "🛡️ Gerenciar Permissões" (botão roxo no topo)
3. Você verá 5 abas: ADMIN, VENDEDOR, COMPRADOR, APROVADOR, GERENTE
```

**✅ Pronto!** Interface de gerenciamento está funcionando.

---

### 3️⃣ Testar (2 minutos)

```
1. Clique na aba "VENDEDOR"
2. Procure a linha "PDV" (Ponto de Venda)
3. Desmarque a caixa "Acessar"
4. Clique "Salvar Alterações"
5. Abra http://localhost:8000/pages/pdv.html
6. Deve redirecionar para dashboard (acesso negado)
7. Volte para gerenciar e marque "Acessar" novamente
8. Salve
9. Recarregue PDV - agora funciona!
```

**✅ Pronto!** O sistema está funcionando corretamente!

---

## 📋 O que foi Criado?

| Arquivo | Tipo | Descrição |
|---------|------|-----------|
| `database/criar-sistema-permissoes.sql` | SQL | Script com 5 tabelas + dados iniciais |
| `js/permissoes.js` | JavaScript | Manager de permissões para as páginas |
| `pages/gerenciar-permissoes.html` | HTML | Interface de administração |
| `GUIA_SISTEMA_PERMISSOES.md` | Documentação | Guia completo com troubleshooting |
| `CHECKLIST_SISTEMA_PERMISSOES.md` | Documentação | Checklist de progresso |

---

## 🎯 5 Modelos de Perfil Disponíveis

### 👨‍💼 ADMIN
- ✅ Acesso total a tudo
- ✅ Pode gerenciar permissões

### 👤 VENDEDOR
- ✅ Dashboard, Produtos, Estoque, Vendas, PDV, Clientes
- ✅ Pode criar vendas
- ❌ Não pode deletar

### 🛒 COMPRADOR
- ✅ Produtos, Fornecedores, Pedidos de Compra
- ✅ Pode criar pedidos
- ❌ Não vê vendas

### ✔️ APROVADOR
- ✅ Análises, Vendas, Pedidos de Compra
- ✅ Pode editar para aprovação
- ❌ Restritivo em exclusão

### 📊 GERENTE
- ✅ Dashboard e Análises
- ❌ Visualização apenas

---

## 🆘 Problemas?

### Problema: "Success" mas vejo "0 rows affected"
**Solução**: As tabelas já existem (executou antes). Está OK!

### Problema: Interface não carrega
**Solução**: Recarregue a página (Ctrl+F5). Limpe cache.

### Problema: Botão "Salvar" não funciona
**Solução**: 
- Verifique console (F12 → Console)
- Verifique se está logado como ADMIN
- Reexecute o script SQL

---

## 📚 Documentação Completa

Para mais detalhes, consulte:
- **GUIA_SISTEMA_PERMISSOES.md** - Guia detalhado com exemplos
- **CHECKLIST_SISTEMA_PERMISSOES.md** - Rastreamento de progresso

---

## ✨ Antes vs Depois

### ❌ Antes (Hardcoded)
```javascript
// Precisava alterar código para mudar permissões
RBACSystem.protegerPagina(['ADMIN', 'VENDEDOR'])
```

### ✅ Depois (Dinâmico)
```javascript
// Apenas marque/desmarque na interface de admin
verificarAcessoModulo('pdv', true)
```

---

## 🎬 Já Configurado

✅ Script SQL pronto para executar
✅ Interface de admin implementada
✅ 2 páginas já usando novo sistema (configuracoes-empresa, pdv)
✅ System de fallback em caso de erro
✅ Suporta 11 módulos diferentes
✅ 5 perfis pré-configurados

---

**Status**: 🟢 **PRONTO PARA USAR**

Execute o SQL script e comece a gerenciar permissões!
