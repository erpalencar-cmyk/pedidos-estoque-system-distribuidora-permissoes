# 🚀 GUIA DE EXECUÇÃO - Proteção de Estoque

## 📋 Ordem de Execução

### **PASSO 1: Validar Estado Atual**
```bash
node database/validar_estoque.js
```

**O que faz:**
- ✅ Identifica duplicatas existentes
- ✅ Verifica produtos/sabores com estoque negativo
- ✅ Lista discrepâncias de estoque
- ✅ Gera relatório completo

**Resultado esperado:**
```
❌ PROBLEMAS CRÍTICOS: 87 movimentações duplicadas
⚠️  AVISOS: X problemas menores
```

---

### **PASSO 2: Corrigir Inconsistências**
```bash
node database/corrigir_inconsistencias_estoque.js
```

**O que faz:**
- 🗑️ Remove movimentações duplicadas
- 🧮 Recalcula estoques com discrepância
- 🎨 Corrige sabores com estoque negativo
- ✅ Valida novamente após correções

**Atenção:** Vai pedir confirmação antes de modificar dados!
```
⚠️  Este script irá MODIFICAR dados do banco. Deseja continuar? (S/N):
```
Digite **S** e pressione Enter.

**Resultado esperado:**
```
✅ CORREÇÃO BEM-SUCEDIDA! Estoque validado com sucesso.
   • Movimentações duplicadas removidas: 174
   • Estoques recalculados: 5
```

---

### **PASSO 3: Aplicar Proteção no Banco**

**1. Abra o Supabase:**
- Acesse: https://supabase.com/dashboard/project/_/sql
- Ou vá em: Dashboard → SQL Editor

**2. Execute o SQL:**
- Abra o arquivo: `database/EXECUTAR_protecao_duplicacao_movimentacoes.sql`
- Copie todo o conteúdo
- Cole no SQL Editor do Supabase
- Clique em **RUN** (ou Ctrl+Enter)

**Resultado esperado:**
```
✅ PROTEÇÃO CONTRA DUPLICAÇÃO IMPLEMENTADA COM SUCESSO!
🛡️ Constraint de finalização: idx_movimentacao_finalização_unica
🛡️ Constraint de cancelamento: idx_movimentacao_cancelamento_unica
```

---

### **PASSO 4: Validar Novamente**
```bash
node database/validar_estoque.js
```

**Resultado esperado:**
```
✅ ESTOQUE VALIDADO COM SUCESSO!
   Não foram encontrados problemas ou inconsistências.
```

---

### **PASSO 5: Testar Proteção**

**Teste 1: Tentar finalizar pedido 2x**
1. Abra o sistema
2. Finalize um pedido
3. Tente finalizar novamente
4. **Resultado:** Deve mostrar "Este pedido já foi finalizado"

**Teste 2: Deixar sessão expirar**
1. Deixe o sistema aberto por 15+ minutos
2. Modal de aviso deve aparecer
3. Se não clicar, deve fazer logout automático

**Teste 3: Verificar movimentações**
1. Vá em Estoque → Movimentações
2. Verifique se aparece:
   - Número do pedido
   - Nome do cliente/fornecedor

---

## 📊 Resumo das Proteções Implementadas

### ✅ **1. Logout Automático (Session Manager)**
- ⏰ 15 minutos de inatividade
- ⚠️ Aviso 2 minutos antes
- 🔒 Validação de sessão a cada minuto
- 📱 Modal visual com contagem regressiva

### ✅ **2. Validação em Operações Críticas**
- 🔐 Verifica sessão antes de finalizar
- ⏰ Valida token JWT
- 🚫 Bloqueia se sessão expirada

### ✅ **3. Constraint Única no Banco**
- 🛡️ Impede duplicatas de finalização
- 🛡️ Impede duplicatas de cancelamento
- ✅ Permite cancelar pedidos finalizados
- ✅ Permite ajustes manuais

### ✅ **4. Scripts de Manutenção**
- 🔍 Validar estoque
- 🔧 Corrigir inconsistências
- 📊 Relatórios detalhados

---

## 🐛 Troubleshooting

### Problema: Script de validação dá erro
**Solução:**
```bash
npm install @supabase/supabase-js
```

### Problema: Constraint não foi criada no banco
**Causa:** Existem duplicatas que impedem criar a constraint
**Solução:** Execute PASSO 2 novamente para limpar duplicatas

### Problema: "Este pedido já foi finalizado" em pedido novo
**Causa:** Banco de dados com dados antigos
**Solução:** Verifique no banco se o pedido realmente não foi finalizado

### Problema: Session Manager não funciona
**Solução:**
```bash
node database/adicionar_session_manager.js
```

---

## ✅ Checklist Final

- [ ] Validação executada
- [ ] Duplicatas corrigidas
- [ ] Constraint aplicada no Supabase
- [ ] Validação pós-correção OK
- [ ] Teste de finalização dupla OK
- [ ] Teste de sessão expirada OK
- [ ] Movimentações mostram pedido/cliente OK

---

## 🎉 Pronto!

Seu sistema agora está:
- ✅ Protegido contra duplicações
- ✅ Com logout automático
- ✅ Com estoque 100% confiável
- ✅ Com rastreabilidade completa

**Cliente feliz! 🚀**

---

## 📞 Suporte

Se encontrar algum problema:
1. Execute novamente: `node database/validar_estoque.js`
2. Verifique os logs no console do navegador (F12)
3. Confira se todas as etapas foram executadas na ordem correta
