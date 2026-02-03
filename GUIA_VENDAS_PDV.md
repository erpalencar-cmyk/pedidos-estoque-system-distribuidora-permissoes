# Guia: Vendas do PDV e Análise Financeira

## 📊 Onde Visualizar Vendas do PDV

Todas as vendas realizadas no PDV são visualizadas em:
- **Menu**: Vendas → [Vendas](pages/vendas.html)
- **URL**: `/pages/vendas.html`

### Características:
- ✅ Mostra todas as vendas (PDV + Manual)
- ✅ Filtro por cliente, status e data
- ✅ Busca por número da venda ou NF-e
- ✅ Visualização de quantidade total e valor
- ✅ Status de pagamento (pago, pendente, parcial)

---

## 💰 Análise Financeira

A análise financeira integra dados de:
1. **Vendas** (manual e PDV)
2. **Contas a Pagar** (compras)
3. **Contas a Receber** (vendas a prazo)

### Acesso:
- **Menu**: Análise → [Análise Financeira](pages/analise-financeira.html)
- **URL**: `/pages/analise-financeira.html`

### Métricas Disponíveis:
- **Receita Total**: Soma de todas as vendas finalizadas
- **Custo Total**: Baseado no `preco_custo` de cada produto
- **Lucro Bruto**: Receita - Custo
- **Margem**: (Lucro / Receita) × 100%

### Filtros:
- Por categoria
- Por marca
- Por período (data início/fim)

### Relatórios:
- 📈 Gráfico de evolução (receitas por dia)
- 📊 Gráfico de análise (receita vs custo vs lucro)
- 💳 Fluxo de caixa (entradas vs saídas)
- 📥 Exportar em Excel ou PDF

---

## 🔄 Fluxo de Dados: PDV → Vendas → Análise

```
┌─────────────────────────────────────────┐
│     PDV (Ponto de Venda)                │
│  - Adiciona itens ao carrinho           │
│  - Define formas de pagamento           │
│  - Finaliza venda                       │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│   Tabela: vendas                        │
│  - numero_nf (auto-gerado)              │
│  - status_venda (FINALIZADA)            │
│  - total (sum de vendas_itens)          │
│  - operador_id (usuário do PDV)         │
│  - created_at (data/hora)               │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│   Tabela: vendas_itens                  │
│  - venda_id (relacionamento)            │
│  - produto_id (item vendido)            │
│  - quantidade                           │
│  - preco_unitario (preço de venda)      │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│   Análise Financeira                    │
│  - Calcula receita (soma de totais)     │
│  - Calcula custo (qty × preco_custo)    │
│  - Gera relatórios e gráficos           │
└─────────────────────────────────────────┘
```

---

## 🐛 Problemas Resolvidos

### ✅ Erro: "Could not find a relationship between 'pedidos_compra' and 'fornecedores'"
**Causa**: Sintaxe incorreta de relacionamento no Supabase
**Solução**: Usando `fornecedores!fornecedor_id()` em vez de `fornecedor:fornecedores()`

### ✅ Vendas do PDV não aparecem em relatórios
**Causa**: Status antigos (`status` em vez de `status_venda`)
**Solução**: Atualizado para `status_venda = 'FINALIZADA'`

### ✅ Campos de data inconsistentes
**Causa**: Referência a `data_venda` que não existe
**Solução**: Usando `created_at` para todas as datas

---

## 📝 Campos Importantes

### Tabela: vendas
| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID | Identificador único |
| numero_nf | VARCHAR | Número da nota fiscal (auto-gerado) |
| status_venda | ENUM | RASCUNHO \| FINALIZADA \| CANCELADA |
| status_fiscal | ENUM | SEM_DOCUMENTO_FISCAL \| EMITIDA \| CANCELADA |
| total | DECIMAL | Valor total da venda |
| operador_id | UUID | Usuário que realizou a venda |
| created_at | TIMESTAMP | Data/hora da venda |

### Tabela: vendas_itens
| Campo | Tipo | Descrição |
|-------|------|-----------|
| venda_id | UUID | Relacionamento com vendas |
| produto_id | UUID | Relacionamento com produtos |
| quantidade | DECIMAL | Quantidade vendida |
| preco_unitario | DECIMAL | Preço de venda |

---

## 🎯 Próximas Implementações

- [ ] NFC-e automática após finalização
- [ ] Dashboard em tempo real
- [ ] Relatório de margem por produto
- [ ] Análise de ticket médio
- [ ] Comparativo período anterior

