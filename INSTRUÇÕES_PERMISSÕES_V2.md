# 🔧 INSTRUÇÕES PARA CORRIGIR O SISTEMA DE PERMISSÕES - V2 INTELIGENTE

## 📋 PROBLEMAS IDENTIFICADOS
1. ❌ `empresa_id` não existe na tabela `usuarios_modulos`
2. ❌ RLS policies bloqueando queries com erro 406
3. ❌ Módulos não mapeados ao sidebar real
4. ❌ Sidebar mostrando módulos que não têm permissão

## ✅ SOLUÇÕES IMPLEMENTADAS

### 1. Código JavaScript Corrigido ✅
- **js/permissoes.js**: Removido TODO `empresa_id` das queries
- **js/permissoes.js**: Fallback agora é **RESTRITIVO** (deny by default)
- **components/sidebar.js**: Mapeamento INTELIGENTE de 37 menu IDs → 20 módulos

### 2. SQL para Executar (CRÍTICO!)

---

## 🚀 PASSO 1: Executar CORRIGIR_RLS_SIMPLES.sql

**ESTE SQL É CRÍTICO - SEM ELE, ERRO 406 CONTINUA!**

**Como fazer**:
1. https://app.supabase.com → Seu projeto
2. **SQL Editor** → **New Query**
3. Copie `database/CORRIGIR_RLS_SIMPLES.sql`
4. Cola e clica **Run** (Ctrl+Enter)
5. Verifica se não tem erro

**Resultado esperado**:
```
✅ CORREÇÃO RLS CONCLUÍDA
Policies criadas: 8 policies
```

---

## 🚀 PASSO 2: Executar INSERIR_MODULOS.sql

**Insere os 20 módulos reais do seu sistema**

**Como fazer**:
1. Mesmo SQL Editor, **New Query**
2. Copie `database/INSERIR_MODULOS.sql`
3. Cola e clica **Run**
4. Verifica se inseriu 20 registros

---

## 📊 MAPEAMENTO: Menu → Módulo (Inteligente)

Seu sidebar tem 37 itens de menu que mapeiam para 20 módulos:

| Menu | Módulo | Descrição |
|------|--------|-----------|
| PDV | pdv | Ponto de Venda |
| Produtos | produtos | Catálogo |
| Estoque | estoque | Movimentações |
| Controle Validade | controle-validade | Vencimentos |
| Comandas | comandas | Atendimento |
| Vendas | vendas | Gerenciamento |
| Caixas | caixas | Configuração |
| Clientes | clientes | Base Clientes |
| Fornecedores | fornecedores | Base Fornecedores |
| Pedidos Compra | pedidos-compra | Compras |
| Contas P Pagar | contas-pagar | Financeiro |
| Contas P Receber | contas-receber | Financeiro |
| Análise Financeira | analise-financeira | Relatórios |
| Documentos Fiscais | documentos-fiscais | NF-e/NFC-e |
| Distribuição NFC-e | distribuicao-nfce | Email NFC-e |
| Usuários | usuarios | Gestão Acesso |
| Aprovar Usuários | aprovacao-usuarios | Gestão Acesso |
| Gerenciar Permissões | gerenciar-permissoes | Gestão Acesso |
| Configurações | configuracoes | Admin |

---

## ⚙️ PASSO 3: Configurar Permissões

1. Vá em: `/pages/gerenciar-permissoes.html`
2. Selecione um usuário
3. Marque os módulos que ele pode acessar
4. Clique "Salvar"

**Padrão**: Usuário sem permissão vê NADA (deny by default ✅)

---

## 🧪 PASSO 4: Testar

Depois de executar os 2 SQLs:

1. Logout e Login novamente
2. Console (F12)
3. Verifico os logs:

**O que você deve VER** ✅:
```
✅ PermissaoManager inicializado
✅ Permissão OK para pdv
🔒 Acesso negado para usuarios
✅ Menu menu-pdv visível
🔒 Menu menu-usuarios oculto
```

**O que você NÃO deve ver** ❌:
```
❌ 406 (Not Acceptable)
❌ column usuarios_modulos.empresa_id does not exist
❌ Todos os 37 menu items visíveis
```

---

## 📝 ARQUIVOS MODIFICADOS

1. **js/permissoes.js** - Removido empresa_id, deny by default
2. **components/sidebar.js** - Mapeamento inteligente de 37 menu IDs
3. **database/CORRIGIR_RLS_SIMPLES.sql** - NOVO
4. **database/INSERIR_MODULOS.sql** - NOVO (20 módulos)

---

**Status**: ✅ Pronto para executar SQL no Supabase  
**Versão**: v2 (Inteligente - Baseado no Sidebar Real)  
**Data**: 2026-02-11
