# 🔧 CORREÇÃO: Reabertura de Pedidos e Vendas

## 📋 Problema Identificado

Ao **cancelar e reabrir** um pedido/venda como RASCUNHO, o sistema estava:
1. ❌ **Revertendo o estoque** (removendo/adicionando itens)
2. ❌ Gerando **movimentações duplicadas** ao refinalizar
3. ❌ Causando **erros de estoque insuficiente** ao tentar cancelar novamente

### Exemplo do Erro:
```
Erro ao cancelar pedido: BLOQUEIO: Não é possível cancelar esta compra! 
O produto IGN-0006 (AÇAI ICE) já foi vendido. 
Estoque atual: 18.00, tentando remover: 20.00. Faltam: 2.00 unidades.
```

## ✅ Solução Implementada

### 1. Correção em `pedido-detalhe.html` (Compras)

#### ANTES (INCORRETO):
```javascript
// Ao reabrir como RASCUNHO
for (const item of itensPedido) {
    // ❌ ERRO: Revertia o estoque
    const ajuste = pedido.tipo_pedido === 'COMPRA' ? -item.quantidade : item.quantidade;
    await supabase.rpc('atualizar_estoque_sabor', {
        p_sabor_id: item.sabor_id,
        p_quantidade: ajuste  // ❌ Criava movimentação
    });
}
```

#### DEPOIS (CORRIGIDO):
```javascript
// Ao reabrir como RASCUNHO
if (novoStatus === 'RASCUNHO' && pedido.status === 'FINALIZADO') {
    // ✅ NÃO mexe no estoque - apenas muda status
    await supabase
        .from('pedidos')
        .update({ 
            status: 'RASCUNHO',
            data_finalizacao: null
        })
        .eq('id', pedidoId);
}
```

### 2. Correção em `venda-detalhe.html` (Vendas)

#### ANTES (INCORRETO):
```javascript
// ❌ SEMPRE devolvia ao estoque (tanto para CANCELADO quanto RASCUNHO)
if (venda.status === 'FINALIZADO') {
    // Devolver produtos ao estoque
    await supabase.rpc('atualizar_estoque_sabor', {
        p_sabor_id: item.sabor_id,
        p_quantidade: item.quantidade  // ❌ Sempre devolvia
    });
}
```

#### DEPOIS (CORRIGIDO):
```javascript
// ✅ Só devolve ao estoque no CANCELAMENTO DEFINITIVO
if (venda.status === 'FINALIZADO' && novoStatus === 'CANCELADO') {
    // ✅ Devolver ao estoque
    await supabase.rpc('atualizar_estoque_sabor', {
        p_sabor_id: item.sabor_id,
        p_quantidade: item.quantidade
    });
} else if (venda.status === 'FINALIZADO' && novoStatus === 'RASCUNHO') {
    // ✅ NÃO mexe no estoque - apenas muda status
    console.log('Reabrindo sem mexer no estoque');
}
```

### 3. Validação Prévia de Estoque

Adicionado em `pedido-detalhe.html` uma validação **ANTES** de tentar cancelar:

```javascript
// ⚠️ Verifica se há estoque suficiente ANTES de cancelar
if (novoStatus === 'CANCELADO' && pedido.tipo_pedido === 'COMPRA') {
    for (const item of itensPedido) {
        const saborAtual = await buscarEstoque(item.sabor_id);
        
        if (saborAtual.quantidade < item.quantidade) {
            alert(
                '⚠️ NÃO É POSSÍVEL CANCELAR!\n' +
                'Produtos já foram vendidos:\n' +
                `• ${saborAtual.codigo} (${saborAtual.sabor}): ` +
                `Necessário: ${item.quantidade}, Disponível: ${saborAtual.quantidade}`
            );
            return;  // ✅ Bloqueia ANTES de tentar cancelar
        }
    }
}
```

## 📊 Lógica Corrigida

### CANCELAMENTO DEFINITIVO (Status → CANCELADO)
```
COMPRA FINALIZADA:
- Pedido: "Comprei 20 unidades" (Estoque +20)
- Cancelar: "Remover 20 unidades" (Estoque -20)
- Resultado: Estoque volta ao valor anterior ✅

VENDA FINALIZADA:
- Venda: "Vendi 5 unidades" (Estoque -5)
- Cancelar: "Devolver 5 unidades" (Estoque +5)
- Resultado: Estoque volta ao valor anterior ✅
```

### REABERTURA COMO RASCUNHO (Status → RASCUNHO)
```
PEDIDO/VENDA FINALIZADA:
- Estoque: Já foi movimentado na finalização
- Reabrir: NÃO mexe no estoque ✅
- Editar: Usuário pode alterar quantidades/itens
- Refinalizar: Sistema calcula diferença e ajusta estoque ✅
```

## 🛡️ Proteções Mantidas

A função SQL `cancelar_pedido_definitivo` continua com todas as proteções:
- ✅ Lock de transação (FOR UPDATE)
- ✅ Validação de estoque antes de cancelar
- ✅ Prevenção de cancelamento duplicado
- ✅ Verificação de status (só cancela FINALIZADOS)

## ✅ Testes Recomendados

1. **Teste de Reabertura**:
   - Finalizar compra de 20 unidades
   - Reabrir como rascunho
   - Verificar que estoque não mudou ✅
   - Refinalizar sem alterações
   - Verificar que estoque não duplicou ✅

2. **Teste de Cancelamento com Estoque**:
   - Finalizar compra de 20 unidades (Estoque: 20)
   - Vender 2 unidades (Estoque: 18)
   - Tentar cancelar compra
   - **ESPERADO**: Mensagem de erro amigável ✅

3. **Teste de Cancelamento Definitivo**:
   - Finalizar compra de 20 unidades (Estoque: 20)
   - Cancelar definitivamente
   - Verificar que estoque voltou a 0 ✅

## 📝 Arquivos Modificados

- ✅ `pages/pedido-detalhe.html` - Corrigida reabertura de compras
- ✅ `pages/venda-detalhe.html` - Corrigida reabertura de vendas
- ✅ Adicionada validação prévia de estoque

## 🚀 Próximos Passos

1. Testar reabertura em ambiente de produção
2. Verificar se há pedidos/vendas já afetados pelo bug
3. Se necessário, executar `EXECUTAR_URGENTE_ajustar_estoque.sql` para reconstruir histórico
