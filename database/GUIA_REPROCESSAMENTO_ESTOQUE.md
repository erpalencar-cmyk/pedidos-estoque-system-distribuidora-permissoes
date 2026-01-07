# 🔄 Guia de Reprocessamento de Estoque

## 📋 Problema Identificado

O sistema está com inconsistências no estoque devido a:
- ✖️ **Movimentações duplicadas** (cancelamentos/finalizações múltiplas)
- ✖️ **Estoque dessincronizado** (valores em `produtos.estoque_atual` diferentes das movimentações)
- ✖️ **Cancelamentos problemáticos** (ordens canceladas e refinalizadas)

---

## 🛠️ Solução Criada

Foram criados **3 scripts SQL** para resolver completamente o problema:

### 1️⃣ `DIAGNOSTICO_estoque_completo.sql`
**O que faz:** Analisa toda a base de dados e identifica problemas
- Produtos com estoque negativo
- Produtos com estoque desatualizado
- Movimentações duplicadas
- Pedidos com múltiplas movimentações
- Top 10 produtos mais afetados

### 2️⃣ `REPROCESSAR_estoque_completo.sql`
**O que faz:** Corrige todos os problemas identificados
- Remove movimentações duplicadas
- Recalcula estoque de todos os produtos
- Cria log de todas as alterações
- Usa transação (permite rollback)

### 3️⃣ `VALIDACAO_estoque.sql`
**O que faz:** Valida que tudo foi corrigido
- 5 testes automatizados
- Relatório final de validação
- Estatísticas do estoque

---

## 📖 Como Executar (Passo a Passo)

### 🔍 PASSO 1: Diagnóstico
```sql
-- Execute no Supabase SQL Editor
-- Arquivo: database/DIAGNOSTICO_estoque_completo.sql
```

**Analise os resultados:**
- Quantos produtos têm problemas?
- Quais pedidos causaram duplicatas?
- Qual a dimensão do problema?

---

### 🔧 PASSO 2: Reprocessamento

**IMPORTANTE:** Este script usa transações. Você deve decidir fazer COMMIT ou ROLLBACK!

```sql
-- Execute no Supabase SQL Editor
-- Arquivo: database/REPROCESSAR_estoque_completo.sql
```

**O script irá:**
1. ✅ Criar backup da situação atual
2. 🔍 Identificar movimentações duplicadas
3. 🗑️ Remover duplicatas
4. 🔄 Recalcular estoque de todos os produtos
5. 📝 Criar log de ajustes
6. ⏸️ PARAR e pedir sua decisão

**Após executar, você verá:**
- Quantos produtos foram ajustados
- Quanto foi ajustado em cada produto
- Quais duplicatas foram removidas

**Decisão final:**
```sql
-- Se TUDO estiver correto:
COMMIT;

-- Se algo estiver errado:
ROLLBACK;
```

---

### ✅ PASSO 3: Validação

Após fazer `COMMIT`, execute:

```sql
-- Execute no Supabase SQL Editor
-- Arquivo: database/VALIDACAO_estoque.sql
```

**Este script executa 5 testes:**
1. ✅ Verificar estoque negativo
2. ✅ Verificar consistência estoque x movimentações
3. ✅ Verificar movimentações duplicadas
4. ✅ Verificar pedidos suspeitos
5. ✅ Verificar log de reprocessamento

**Resultado esperado:**
```
✅ TODOS OS TESTES PASSARAM!
```

---

## 🎯 O Que o Reprocessamento Faz

### Antes (Problema):
```
Produto A:
- Estoque registrado: 50
- Movimentações:
  ✅ Entrada: +100
  ❌ Saída: -30 (duplicada)
  ❌ Saída: -30 (duplicada)
  ✅ Saída: -20
- Estoque calculado deveria ser: 50, mas está 20!
```

### Depois (Corrigido):
```
Produto A:
- Estoque registrado: 50
- Movimentações:
  ✅ Entrada: +100
  ✅ Saída: -30 (única)
  ✅ Saída: -20
- Estoque calculado: 50 ✅
```

---

## 📊 Log de Reprocessamento

Todos os ajustes ficam registrados na tabela:
```sql
estoque_reprocessamento_log
```

Você pode consultar:
```sql
SELECT 
    codigo_produto,
    nome_produto,
    estoque_anterior,
    estoque_recalculado,
    diferenca,
    reprocessado_em
FROM estoque_reprocessamento_log
ORDER BY reprocessado_em DESC;
```

---

## 🔒 Segurança

### O script é seguro porque:
1. ✅ Usa **transação** (BEGIN/COMMIT/ROLLBACK)
2. ✅ Cria **backup temporário** antes de qualquer mudança
3. ✅ **Mostra tudo** que será alterado antes de alterar
4. ✅ **Espera sua confirmação** (você decide COMMIT ou ROLLBACK)
5. ✅ **Registra tudo** em log
6. ✅ **Pode ser revertido** (ROLLBACK) se algo der errado

### Se algo der errado:
```sql
-- Cancela TUDO e volta ao estado anterior
ROLLBACK;

-- O backup temporário será mantido até o fim da sessão
SELECT * FROM backup_estoque_antes_reprocessamento;
```

---

## 🎓 Entendendo as Duplicatas

### Como surgem duplicatas?
1. Usuário finaliza pedido → Cria movimentação de SAÍDA
2. Usuário cancela pedido → Cria movimentação de ENTRADA (estorno)
3. Sistema trava ou erro ocorre
4. Usuário finaliza novamente → **Cria nova movimentação de SAÍDA** (DUPLICATA!)

### Como o script resolve?
O script identifica duplicatas por:
- Mesmo pedido
- Mesmo produto
- Mesmo tipo de movimentação
- Mesma quantidade
- Mesmo dia

**Mantém apenas a PRIMEIRA ocorrência** e remove as duplicatas.

---

## 📈 Melhor Prática Futura

### Para evitar o problema novamente:

1. **Execute validação periódica:**
```sql
-- 1x por semana
database/DIAGNOSTICO_estoque_completo.sql
```

2. **Implemente proteção contra duplicatas:**
```sql
-- Já existe em: database/EXECUTAR_protecao-cancelamento-duplo.sql
-- Garante que pedidos cancelados não podem ser cancelados novamente
```

3. **Monitore movimentações:**
```sql
-- Alerta de duplicatas
SELECT 
    ped.numero,
    p.nome,
    COUNT(*) as movimentacoes
FROM estoque_movimentacoes em
JOIN pedidos ped ON em.pedido_id = ped.id
JOIN produtos p ON em.produto_id = p.id
GROUP BY ped.numero, p.nome, em.tipo, em.quantidade, DATE(em.created_at)
HAVING COUNT(*) > 1;
```

---

## ❓ FAQ

### Q: O reprocessamento vai apagar minhas movimentações?
**R:** Não! Ele apenas remove **duplicatas** (cópias idênticas no mesmo dia). As movimentações originais são mantidas.

### Q: Posso executar o reprocessamento quantas vezes quiser?
**R:** Sim! O script é **idempotente**. Se executar 2x seguidas, a segunda não fará nada (pois já está correto).

### Q: E se eu cometer um erro?
**R:** Use `ROLLBACK;` para cancelar tudo. O backup temporário permite reverter.

### Q: Quanto tempo leva?
**R:** Depende do tamanho da base. Para bases com até 10.000 produtos e 100.000 movimentações, leva menos de 1 minuto.

### Q: Posso executar em produção?
**R:** Sim, mas recomendamos:
1. Fazer backup do banco completo primeiro
2. Executar em horário de baixo movimento
3. Avisar usuários sobre manutenção

---

## 📞 Suporte

Se encontrar problemas:
1. Execute `ROLLBACK;` imediatamente
2. Copie os erros do console
3. Execute novamente o diagnóstico
4. Revise os resultados antes de tentar novamente

---

## ✅ Checklist de Execução

- [ ] 1. Fazer backup do banco de dados
- [ ] 2. Executar `DIAGNOSTICO_estoque_completo.sql`
- [ ] 3. Revisar problemas encontrados
- [ ] 4. Executar `REPROCESSAR_estoque_completo.sql`
- [ ] 5. Revisar ajustes propostos
- [ ] 6. Decidir: `COMMIT;` ou `ROLLBACK;`
- [ ] 7. Executar `VALIDACAO_estoque.sql`
- [ ] 8. Confirmar: ✅ TODOS OS TESTES PASSARAM!
- [ ] 9. Testar funcionalidade no sistema
- [ ] 10. Monitorar por alguns dias

---

**Criado em:** {{ date }}  
**Versão:** 1.0  
**Status:** ✅ Pronto para uso
