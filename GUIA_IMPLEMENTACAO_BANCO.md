# 🗄️ GUIA DE IMPLEMENTAÇÃO - BANCO DE DADOS

## 📊 ANÁLISE DO SCHEMA

### ✅ Status do Schema Novo
- **Tabelas:** 17 principais
- **Procedures:** 1 (finalizar_venda_segura com LOCK)
- **Functions:** 4 (atualizar_estoque, saldo_cliente, gerar_número, update_timestamp)
- **Triggers:** 9 (para manter dados sincronizados)
- **Views:** 3 (dashboard, estoque_critico, contas_vencidas)
- **RLS Policies:** 4 (segurança por role)
- **Tipos ENUMs:** 5 customizados

### 📋 Tabelas Implementadas

#### 🏢 Tabelas Base
| Tabela | Função | Registros |
|--------|--------|-----------|
| `empresa_config` | Configurações fiscais, NFe, PDV | 1 |
| `users` | Usuários com 7 roles | N |
| `clientes` | Clientes PJ/PF com limite | N |
| `fornecedores` | Fornecedores com contatos | N |

#### 📦 Tabelas de Catálogo
| Tabela | Função |
|--------|--------|
| `categorias` | 8 categorias padrão |
| `marcas` | 10 marcas padrão |
| `produtos` | SKU + código_barras + preços |
| `produto_lotes` | Controle de lotes/vencimento |

#### 💳 Tabelas de Vendas
| Tabela | Função |
|--------|--------|
| `caixas` | 3 caixas PDV |
| `movimentacoes_caixa` | Sessões abertas/fechadas |
| `vendas` | Pedidos finalizados |
| `vendas_itens` | Itens das vendas |
| `pagamentos_venda` | Formas de pagamento |

#### 📄 Tabelas Fiscais
| Tabela | Função |
|--------|--------|
| `documentos_fiscais` | NFC-e / NF-e emitidas |
| `contas_receber` | Financeiro a receber |
| `estoque_movimentacoes` | Rastreamento entrada/saída |
| `auditoria_log` | Log de todas operações |

### 🔐 Segurança Implementada

#### Roles (7)
1. `ADMIN` - Acesso total
2. `GERENTE` - Gerenciamento do negócio
3. `VENDEDOR` - Criar pedidos
4. `OPERADOR_CAIXA` - Apenas vendas no PDV
5. `ESTOQUISTA` - Movimentação de estoque
6. `COMPRADOR` - Compras/fornecedores
7. `APROVADOR` - Aprovações

#### RLS Policies
- `users`: Só lê seus próprios dados (ou ADMIN)
- `vendas`: Filtra por role (ADMIN/GERENTE/OPERADOR_CAIXA)
- `estoque_movimentacoes`: Filtra por role
- `auditoria_log`: Filtra por role

### ⚡ Performance
- **Índices:** 9 índices criados
  - `idx_vendas_data` (queries por data)
  - `idx_vendas_caixa` (filtro por caixa)
  - `idx_vendas_cliente` (filtro por cliente)
  - `idx_estoque_mov_tipo` (filtro por movimento)

---

## 🚀 SEQUÊNCIA DE EXECUÇÃO

### PASSO 1️⃣ - Limpar Banco (Recomendado)
```bash
# Remover todos os dados, tabelas, funções antigas
# Arquivo: 00-LIMPAR_BANCO.sql
```
**Quando usar:**
- ✓ Primeira vez
- ✓ Começar do zero
- ✓ Remover schema antigo

**O que remove:**
- Todas as 17 tabelas
- Todas as 4 functions
- Todos os 9 triggers
- Todas as 3 views
- Todos os 4 políticas RLS
- Todos os 5 tipos ENUM

---

### PASSO 2️⃣ - Criar Schema Novo
```bash
# Criar estrutura completa do novo sistema
# Arquivo: schema-novo-distribuidora.sql
```
**Tempo:** ~5 segundos
**Inclui:**
- 17 tabelas
- 4 functions
- 9 triggers
- 3 views
- 4 RLS policies
- Dados iniciais (8 categorias, 10 marcas, 3 caixas)

---

### PASSO 3️⃣ - Criar Procedures (Transações)
```bash
# Operações complexas com lock e validação
# Arquivo: stored-procedures-novo.sql
```
**Funções importantes:**
1. `finalizar_venda_segura()` - Com lock (race condition)
2. Outras procedures de negócio

---

## 🔍 VALIDAÇÃO DE COERÊNCIA

### ✅ Verificação 1: Tabelas vs JavaScript

| JavaScript | Tabela BD | Status |
|------------|-----------|--------|
| PDVSystem.adicionarItem() | vendas_itens | ✓ |
| PDVSystem.finalizarVenda() | vendas + movimentacoes_caixa | ✓ |
| PDVSystem.registrarMovimentoEstoque() | estoque_movimentacoes | ✓ |
| FiscalSystem.emitirNFCe() | documentos_fiscais | ✓ |
| RBACSystem.registrarAuditoria() | auditoria_log | ✓ |
| PedidosService.criarPedido() | vendas + vendas_itens | ✓ |

### ✅ Verificação 2: Funcionalidades HTML vs Schema

#### 📄 PDV (pages/pdv.html)
```
Funcionalidades Mapeadas:
✓ Abertura de caixa → movimentacoes_caixa
✓ Buscar produto → produtos + codigo_barras
✓ Adicionar ao carrinho → vendas_itens (em memória)
✓ Finalizar venda → vendas + finalizar_venda_segura()
✓ Emitir NFC-e → documentos_fiscais
✓ Imprimir cupom → gerarCupom()
✓ Fechar caixa → movimentacoes_caixa.status='FECHADA'
```

#### 📋 Pedidos (pages/pedidos.html)
```
Funcionalidades Mapeadas:
✓ Listar pedidos → SELECT vendas
✓ Criar pedido → INSERT vendas + vendas_itens
✓ Atualizar pedido → UPDATE vendas
✓ Cancelar pedido → UPDATE vendas.status='CANCELADA'
✓ Emitir NFC-e → documentos_fiscais
✓ Consultar por chave → documentos_fiscais.chave_acesso
```

#### 👥 Clientes (pages/clientes.html)
```
Funcionalidades Mapeadas:
✓ Listar clientes → SELECT clientes
✓ Criar cliente → INSERT clientes
✓ Editar cliente → UPDATE clientes
✓ Verificar saldo → clientes.saldo_devedor
✓ Ver contas a receber → contas_receber WHERE cliente_id
```

#### 📦 Estoque (pages/estoque.html)
```
Funcionalidades Mapeadas:
✓ Listar produtos → SELECT produtos
✓ Atualizar estoque → UPDATE produtos.estoque_atual
✓ Registrar movimento → INSERT estoque_movimentacoes
✓ Produtos críticos → v_estoque_critico VIEW
✓ Histórico movimentação → SELECT estoque_movimentacoes
```

#### ⚙️ Configurações (pages/configuracoes-empresa.html)
```
Funcionalidades Mapeadas:
✓ Dados empresa → empresa_config
✓ Configuração fiscal (NFe/NFC-e) → empresa_config
✓ Configuração WhatsApp → empresa_config
✓ Configuração PDV → empresa_config
```

---

## ⚠️ PONTOS CRÍTICOS

### 1. Race Condition em Vendas
```sql
-- ✓ RESOLVIDO: usar finalizar_venda_segura()
-- Usa lock (FOR UPDATE) implícito na transação
-- Garante atomicidade
```

### 2. Sincronização de Estoque
```sql
-- ✓ RESOLVIDO: trigger update_vendas_estoque
-- Reduz estoque automaticamente ao finalizar venda
-- Mantém estoque_atual sincronizado
```

### 3. Saldo Devedor de Cliente
```sql
-- ✓ RESOLVIDO: trigger update_contas_saldo_cliente
-- Atualiza automaticamente contas_receber
-- Mantém saldo_devedor sincronizado
```

### 4. Auditoria
```sql
-- ✓ IMPLEMENTADO: tabela auditoria_log
-- Registra: tabela, operação, usuário, IP, dados antes/depois
-- Protegido com RLS por role
```

---

## 📱 TELAS E FUNCIONALIDADES

### Páginas Principais (Implementadas)

#### 1. **PDV (pages/pdv.html)**
```
✓ Abertura de caixa (saldo inicial)
✓ Buscar produto por código/barras
✓ Adicionar item ao carrinho
✓ Remover item do carrinho
✓ Aplicar desconto por item/total
✓ Finalizar venda (5 formas pagamento)
✓ Gerar e imprimir cupom
✓ Emitir NFC-e (integração Focus)
✓ Fechar caixa (conferência)
✓ Auditoria completa
```

#### 2. **Pedidos (pages/pedidos.html)**
```
✓ Listar pedidos (filtros: cliente, data, status)
✓ Criar novo pedido/pré-pedido
✓ Adicionar itens com preço customizado
✓ Cancelar pedido
✓ Gerar PDF
✓ Enviar por WhatsApp
✓ Emitir NFC-e/NF-e
✓ Consultar NF-e por chave
✓ Estatísticas de pedidos
```

#### 3. **Clientes (pages/clientes.html)**
```
✓ Listar clientes (PJ/PF)
✓ Criar/Editar cliente
✓ Definir limite de crédito
✓ Visualizar saldo devedor
✓ Ver contas a receber
✓ Histórico de compras
```

#### 4. **Estoque (pages/estoque.html)**
```
✓ Listar produtos com estoque
✓ Buscar por SKU/código_barras
✓ Atualizar preços (custo/venda)
✓ Registrar movimento (entrada/saída)
✓ Controle de lotes/vencimento
✓ Produtos em falta (críticos)
✓ Relatório de movimentações
```

#### 5. **Configurações (pages/configuracoes-empresa.html)**
```
✓ Dados da empresa (CNPJ, IE, razão social)
✓ Endereço e contatos
✓ Configuração fiscal (regime, CNAE)
✓ Focus NFe (token, série, ambiente)
✓ PDV (emitir NFC-e, imprimir, descontos)
✓ WhatsApp (integração)
✓ Usuários e roles
✓ Permissões por role
```

#### 6. **Dashboard (pages/dashboard.html)**
```
✓ Vendas do dia (gráfico)
✓ Ticket médio
✓ Produtos mais vendidos
✓ Formas de pagamento
✓ Estoque crítico
✓ Contas a receber vencidas
✓ Últimas transações
```

---

## 🎯 CHECKLIST PRÉ-IMPLEMENTAÇÃO

### ✅ Banco de Dados
- [ ] Executar `00-LIMPAR_BANCO.sql` (remover schema antigo)
- [ ] Executar `schema-novo-distribuidora.sql` (criar novo schema)
- [ ] Executar `stored-procedures-novo.sql` (procedures com lock)
- [ ] Verificar `SELECT * FROM empresa_config` (dados iniciais)
- [ ] Verificar `SELECT * FROM categorias` (8 categorias)
- [ ] Verificar `SELECT * FROM marcas` (10 marcas)
- [ ] Verificar `SELECT * FROM caixas` (3 caixas PDV)

### 🔐 Segurança
- [ ] Criar usuário ADMIN com role 'ADMIN'
- [ ] Criar usuário OPERADOR_CAIXA com role 'OPERADOR_CAIXA'
- [ ] Criar usuário GERENTE com role 'GERENTE'
- [ ] Testar RLS: usuário operador não vê dados de outros

### 🧪 Testes Funcionais
- [ ] Abrir caixa (PDV)
- [ ] Buscar produto por código de barras
- [ ] Adicionar item ao carrinho
- [ ] Finalizar venda (testar com lock)
- [ ] Gerar cupom (verifica gerarCupom())
- [ ] Criar pedido (verifica PedidosService)
- [ ] Emitir NFC-e (verifica FiscalSystem)
- [ ] Registrar movimento de estoque
- [ ] Verificar auditoria de acesso

---

## 📞 SUPORTE

### Dúvidas Frequentes

**P: Qual script executar primeiro?**
A: `00-LIMPAR_BANCO.sql` (opcional, se tem schema antigo) → `schema-novo-distribuidora.sql` → `stored-procedures-novo.sql`

**P: Posso pular a limpeza?**
A: Não recomendado. Pode haver conflito de tipos ENUM, tabelas duplicadas, ou policies antigas ativas.

**P: Posso usar Supabase SQL Editor?**
A: Sim! Copie o conteúdo de cada arquivo e execute um por um na seção "SQL Editor" do Supabase.

**P: Como testar se está funcionando?**
A: Abra `pages/pdv.html` no navegador. Se carrega sem erro, schema está correto.

---

## 📈 Próximas Fases

- **P1:** Consolidação de funções (gerarHTMLPedido)
- **P2:** Lock em PDV (race condition)
- **P3:** Standardização de componentes
- **P4:** Cache com TTL

---

**Última atualização:** Fev 3, 2026
**Status:** Pronto para implementação ✅
