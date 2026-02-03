# ⚡ GUIA RÁPIDO - Executar Migrations no Supabase

## 🔴 PROBLEMA ENCONTRADO
```
Error: Could not find the 'troco' column of 'vendas' in the schema cache
```

**Causa**: A coluna `troco` não foi criada na tabela `vendas` no Supabase.

**Solução**: Executar as migrations SQL no Supabase.

---

## 📋 Migrations Necessárias

### Migration 1️⃣: Adicionar Colunas em PRODUTOS
- **Arquivo**: `database/migrations/003_adicionar_cfop_compra.sql`
- **O que faz**: Adiciona ~20 colunas faltando na tabela `produtos`
- **Tempo estimado**: 5-10 segundos

### Migration 2️⃣: Adicionar TROCO em VENDAS  
- **Arquivo**: `database/migrations/004_adicionar_troco_vendas.sql`
- **O que faz**: Adiciona coluna `troco` na tabela `vendas`
- **Tempo estimado**: 1-2 segundos

---

## 🚀 PASSO A PASSO - Como Executar

### Passo 1: Acessar Supabase SQL Editor
1. Abrir: **https://app.supabase.com**
2. Fazer login se necessário
3. Selecionar seu projeto (ex: "pedidos-estoque-system")
4. No menu lateral, clicar em: **SQL Editor**

### Passo 2: Executar Migration 003
1. Clicar em: **New Query** (botão azul)
2. Uma aba nova abre
3. Copiar TODO O CONTEÚDO de:
   ```
   database/migrations/003_adicionar_cfop_compra.sql
   ```
4. Colar no SQL Editor (Ctrl+V)
5. Clicar em: **RUN** (botão verde)
6. ✅ Aguardar "Successfully executed" (status verde)
7. Verificar output - deve mostrar múltiplos comandos executados

### Passo 3: Executar Migration 004
1. Clicar em: **New Query** (botão azul)
2. Copiar TODO O CONTEÚDO de:
   ```
   database/migrations/004_adicionar_troco_vendas.sql
   ```
3. Colar no SQL Editor
4. Clicar em: **RUN** (botão verde)
5. ✅ Aguardar "Successfully executed"
6. Verificar output - deve mostrar "ALTER TABLE ... ADD COLUMN IF NOT EXISTS troco"

---

## ✅ Verificação - Confirmar que Funcionou

### Verificar Migration 003 (PRODUTOS)
```sql
-- Execute no Supabase SQL Editor:
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'produtos' AND column_name = 'troco';
```
Resultado esperado: Mostra coluna `troco` ou vazia (coluna não faz parte de produtos, era teste)

### Verificar Migration 004 (VENDAS)
```sql
-- Execute no Supabase SQL Editor:
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'vendas' AND column_name = 'troco';
```
Resultado esperado: **troco** (deve aparecer a coluna)

---

## 🧪 Testar No PDV

Após executar as migrations:

1. Abrir PDV: **http://localhost:8000/pages/pdv.html**
2. Fazer login
3. Abrir caixa
4. Adicionar algum produto ao carrinho
5. Clicar em: **Finalizar Venda**
6. Digitar um valor maior que o total
7. Verificar se o **troco calcula corretamente**
8. ✅ Clicar em **Confirmar**
9. ✅ Deve processar sem erro

---

## 🆘 Se Ainda Tiver Erro

### Opção 1: Limpar Cache
1. Abrir DevTools (F12)
2. Ir para: **Application → Storage → Clear site data**
3. Recarregar página (F5)
4. Tentar novamente

### Opção 2: Verificar Logs
1. Abrir DevTools (F12)
2. Ir para: **Console**
3. Fazer a operação que tá dando erro
4. Copiar a mensagem de erro exata
5. Procurar pelo nome da coluna no SQL do Supabase

### Opção 3: Executar SQL de Diagnóstico
```sql
-- No Supabase SQL Editor, execute:
SELECT * FROM vendas LIMIT 1;
```

Se der erro tipo "column 'troco' does not exist", a migration 004 não foi executada ainda.

---

## 📊 Checklist

- [ ] Abrir Supabase SQL Editor
- [ ] Copiar Migration 003 (produtos)
- [ ] Executar Migration 003 ✅
- [ ] Copiar Migration 004 (vendas/troco)
- [ ] Executar Migration 004 ✅
- [ ] Verificar erro desapareceu no PDV
- [ ] Testar finalizar venda completo
- [ ] ✅ Pronto!

---

## 📝 Dúvidas Comuns

**P: Quanto tempo leva?**  
R: Menos de 1 minuto total (incluindo copiar/colar)

**P: Posso executar as duas ao mesmo tempo?**  
R: Não, executar uma por uma é mais seguro

**P: E se tiver erro na Migration 003?**  
R: Tente novamente - às vezes é só problema de timeout. Se persistir, procure por "IF NOT EXISTS" no SQL (significa que a coluna pode já existir)

**P: A Migration 004 é urgente?**  
R: Sim! Sem ela não consegue finalizar venda com o campo `troco`

---

## 🎯 Próximos Passos

1. ✅ Executar as 2 migrations acima
2. 🧪 Testar finalizacao de venda no PDV
3. 📊 Verificar se os dados estão sendo salvos no Supabase
4. 🚀 Sistema deve estar 100% funcional!

