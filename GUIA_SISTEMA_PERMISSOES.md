# 🔐 Guia do Sistema de Permissões Dinâmicas

## Visão Geral

Este sistema permite que o administrador configure quais módulos cada perfil de usuário pode acessar, sem necessidade de alterar código.

**Anteriormente**: Permissões eram hardcoded nas páginas como `RBACSystem.protegerPagina(['ADMIN'])`

**Agora**: Permissões são gerenciadas através de uma interface de administração conectada ao banco de dados.

---

## 1️⃣ Executar o Script SQL no Supabase

### Passo 1: Acessar o SQL Editor do Supabase

1. Acesse [https://app.supabase.com](https://app.supabase.com)
2. Selecione seu projeto
3. Clique em **"SQL Editor"** na barra lateral esquerda
4. Clique em **"New Query"**

### Passo 2: Copiar e Colar o Script

1. Abra o arquivo `database/criar-sistema-permissoes.sql` em seu editor
2. Copie **TODO** o conteúdo do arquivo
3. Cole no SQL Editor do Supabase
4. Clique em **"Run"** (button verde no canto superior direito)

### Passo 3: Verificar Execução

Você verá uma mensagem como:
```
Success. 227 rows affected
```

**Tabelas criadas:**
- ✅ `modulos` - Lista de módulos do sistema
- ✅ `perfis` - Perfis de usuário (ADMIN, VENDEDOR, etc.)
- ✅ `permissoes_modulos` - Ligação entre perfis e módulos
- ✅ `acoes_modulo` - Ações customizáveis por módulo
- ✅ `permissoes_acoes` - Permissões de ação por perfil

---

## 2️⃣ Acessar a Interface de Gerenciamento

### Acesso pelo Admin Painel

1. Acesse `http://localhost:8000/admin-painel.html`
2. Clique em **"Gerenciar Permissões"** (botão roxo no topo)
3. Você será levado para a página `/pages/gerenciar-permissoes.html`

### Permissões Necessárias

Apenas usuários com role **ADMIN** podem acessar esta página.

---

## 3️⃣ Interface de Gerenciamento

### Estrutura

```
┌─────────────────────────────────────────────┐
│ 🛡️ Gerenciar Permissões                    │
├─────────────────────────────────────────────┤
│ [ADMIN] [VENDEDOR] [COMPRADOR] [GERENTE]  │
├─────────────────────────────────────────────┤
│ Módulo  │ Acessar │ Criar │ Editar │ Deletar │
├─────────────────────────────────────────────┤
│ Dashboard │   ✓   │  ✓   │   ✓   │   ✓    │
│ Produtos  │   ✓   │  ✓   │   ✓   │   ✓    │
│ Estoque   │   ✓   │  ✓   │   ✓   │   ✓    │
│ ...       │ ...   │ ...  │  ...  │  ...   │
├─────────────────────────────────────────────┤
│          [Redefinir]  [Salvar Alterações]  │
└─────────────────────────────────────────────┘
```

### Como Usar

1. **Selecione um Perfil**: Clique na aba do perfil desejado
2. **Configure Permissões**: Marque/desmarque os checkboxes
   - **Acessar**: Usuário pode visualizar este módulo
   - **Criar**: Usuário pode criar novos registros
   - **Editar**: Usuário pode editar registros existentes
   - **Deletar**: Usuário pode deletar registros
3. **Salve as Alterações**: Clique em "Salvar Alterações"

---

## 4️⃣ Módulos Disponíveis

| Slug | Nome | Descrição |
|------|------|-----------|
| `dashboard` | Dashboard | Página inicial e resumos |
| `produtos` | Produtos | Catálogo e cadastro de produtos |
| `estoque` | Estoque | Controle de inventário |
| `vendas` | Vendas | Registro de vendas |
| `pedidos-compra` | Pedidos de Compra | Pedidos para fornecedores |
| `fornecedores` | Fornecedores | Cadastro de fornecedores |
| `clientes` | Clientes | Cadastro de clientes |
| `analises` | Análises Financeiras | Relatórios e análises |
| `configuracoes` | Configurações | Configurações da empresa |
| `usuarios` | Usuários | Gerenciamento de usuários |
| `pdv` | PDV | Sistema de ponto de venda |

---

## 5️⃣ Perfis Pré-configurados

### ADMIN
- Acesso total a todos os módulos
- Permissão para criar, editar e deletar
- Pode gerenciar permissões de outros usuários

### VENDEDOR
- Pode acessar: Dashboard, Produtos, Estoque, Vendas, PDV, Clientes
- Pode criar vendas
- Não pode deletar registros

### COMPRADOR
- Pode acessar: Produtos, Fornecedores, Pedidos de Compra
- Pode criar pedidos de compra
- Não pode deletar fornecedores

### APROVADOR
- Pode acessar: Dashboard, Análises, Vendas, Pedidos de Compra
- Permissões de edição para aprovação
- Restrições em exclusão

### GERENTE
- Pode acessar: Dashboard, Análises, Vendas, Estoque
- Visualização apenas
- Não pode criar/editar/deletar

---

## 6️⃣ Implementação nas Páginas

### Antes (Hardcoded)
```javascript
// ❌ Anterior - Permissão fixa no código
RBACSystem.protegerPagina(['ADMIN', 'VENDEDOR'])
```

### Depois (Dinâmico)
```javascript
// ✅ Novo - Verifica permissão no banco de dados
verificarAcessoModulo('pdv', true)
```

### Páginas Já Atualizadas
- ✅ `configuracoes-empresa.html`
- ✅ `pdv.html`

### Páginas Ainda Usando Sistema Antigo

Para atualizar outras páginas, siga este padrão:

1. **Adicione import do sistema de permissões**:
```html
<script src="../js/permissoes.js"></script>
```

2. **Substitua a verificação**:
```javascript
// De:
RBACSystem.protegerPagina(['ADMIN', 'GERENTE'])

// Para:
verificarAcessoModulo('modulo-slug', true)
```

---

## 7️⃣ Sistema de Fallback

Se a tabela de permissões não estiver disponível (erro no SQL ou desconexão), o sistema usa permissões hardcoded como fallback:

```javascript
// Em js/permissoes.js
_verificarPermissaoLocal(role, modulo) {
    const permissoes = {
        'ADMIN': ['*'],  // Acesso total
        'VENDEDOR': ['dashboard', 'produtos', 'estoque', 'vendas', 'pdv', 'clientes'],
        'COMPRADOR': ['produtos', 'fornecedores', 'pedidos-compra'],
        // ... mais perfis
    }
    return permissoes[role]?.includes(modulo) ?? permissoes[role]?.includes('*') ?? false;
}
```

---

## 8️⃣ Testando o Sistema

### Teste 1: Verificar Tabelas Criadas

Acesse **SQL Editor** → **New Query** e execute:
```sql
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('modulos', 'perfis', 'permissoes_modulos');
```

Resultado esperado:
```
modulos
perfis
permissoes_modulos
```

### Teste 2: Verificar Dados

```sql
SELECT nome FROM modulos ORDER BY ordem;
SELECT nome FROM perfis;
```

### Teste 3: Verificar Permissões

```sql
SELECT pm.*, m.nome as modulo, p.nome as perfil
FROM permissoes_modulos pm
JOIN modulos m ON pm.modulo_id = m.id
JOIN perfis p ON pm.perfil_id = p.id
WHERE p.nome = 'VENDEDOR';
```

### Teste 4: Acessar Interface

1. Acesse `http://localhost:8000/admin-painel.html`
2. Clique em "Gerenciar Permissões"
3. Você deve ver as abas com os perfis
4. Experimente marcar/desmarcar permissões
5. Clique "Salvar Alterações"

---

## 9️⃣ Troubleshooting

### Problema: "Acesso negado" na página de permissões

**Solução**: 
- Verifique se você está logado como ADMIN
- Verifique se a role do usuário no banco está como 'ADMIN'

### Problema: Tabelas de permissões não aparecem

**Solução**:
- Execute novamente o script SQL em `database/criar-sistema-permissoes.sql`
- Verifique se não há erros na execução do SQL
- Recarregue a página (Ctrl+F5)

### Problema: Permissões não salvam

**Solução**:
- Verifique a console do navegador (F12 → Console) para erros
- Verifique se as políticas RLS estão habilitadas
- Tente reexecutar o script SQL

### Problema: Interface diferente do esperado

**Solução**:
- Verifique se `js/permissoes.js` foi carregado (F12 → Network)
- Verifique se o Tailwind CSS está carregando
- Limpe o cache do navegador (Ctrl+Shift+Delete)

---

## 🔟 Próximas Etapas

1. **Executar o Script SQL** no Supabase
2. **Acessar a Interface** de Gerenciamento
3. **Configurar Permissões** para cada perfil
4. **Testar** com usuários de diferentes perfis
5. **Atualizar Páginas Restantes** para usar novo sistema

---

## 📞 Suporte

Para dúvidas ou problemas:

1. Verifique este guia
2. Consulte a seção "Troubleshooting"
3. Verifique a console do navegador (F12)
4. Verifique os logs do Supabase

---

**Última atualização**: 2024
**Status**: ✅ Sistema Implementado e Pronto para Uso
