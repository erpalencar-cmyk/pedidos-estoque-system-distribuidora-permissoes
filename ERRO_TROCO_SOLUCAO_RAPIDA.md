# ❌ ERRO: Coluna TROCO Faltando

## O Problema
Quando você tenta finalizar uma venda, aparece este erro:
```
Could not find the 'troco' column of 'vendas' in the schema cache
```

## Por Quê?
A coluna `troco` não foi criada na tabela `vendas` no banco de dados Supabase.

## Solução (5 MINUTOS)

### ✅ PASSO 1: Copiar Código SQL

Copie EXATAMENTE este código:

```sql
ALTER TABLE vendas ADD COLUMN IF NOT EXISTS troco DECIMAL(12,2) DEFAULT 0;
CREATE INDEX IF NOT EXISTS idx_vendas_troco ON vendas(troco);
```

### ✅ PASSO 2: Ir para Supabase

1. Abrir: https://app.supabase.com
2. Fazer login com sua conta
3. Clique no projeto: "pedidos-estoque-system" (ou o nome do seu)
4. No menu à esquerda, clique em: **SQL Editor**

### ✅ PASSO 3: Executar SQL

1. Clique em: **New Query** (botão azul)
2. Apague qualquer coisa que tiver dentro
3. **Cole o código SQL acima** (Ctrl+V)
4. Clique em: **RUN** (botão verde grande)
5. Aguarde aparecer: ✅ **Successfully executed**

### ✅ PASSO 4: Testar

1. Volte para o PDV: http://localhost:8000/pages/pdv.html
2. Abra um caixa
3. Adicione um produto
4. Clique em "Finalizar Venda"
5. Digite um valor
6. Clique em "Confirmar"
7. ✅ Deve funcionar agora!

---

## 🆘 Deu Erro?

### Se aparecer: "ALREADY EXISTS"
- Significa que a coluna já foi criada antes
- Tudo bem! Continue para o Passo 4 (Testar)

### Se aparecer outro erro
- Copie exatamente o código acima (sem espaços extras)
- Tente de novo
- Se continuar, procure por esse erro no Google

---

## 📞 Resumo Rápido

| O Quê | Onde | Tempo |
|-------|------|-------|
| 1. Copiar código SQL | Acima ☝️ | 10 seg |
| 2. Ir para Supabase | https://app.supabase.com | 20 seg |
| 3. Executar SQL | SQL Editor → New Query | 30 seg |
| 4. Testar no PDV | http://localhost:8000/pages/pdv.html | 1 min |
| **TOTAL** | - | **~2 min** |

---

**Pronto! O erro deve desaparecer.**

