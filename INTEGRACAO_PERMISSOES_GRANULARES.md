-- =====================================================
-- INTEGRAÇÃO DE PERMISSÕES GRANULARES DO SISTEMA
-- =====================================================
-- Este arquivo documenta como o sistema de permissões funciona agora
-- e como adicionar permissões granulares a novas páginas

## 🎯 SISTEMA DE PERMISSÕES AGORA INTEGRADO

O sistema agora usa **dois níveis de permissões**:

### 1️⃣ Nível ROLE (Básico)
- Controla acesso por **ROLE** (ADMIN, GERENTE, VENDEDOR, etc)
- Definido em: `js/auth-rbac.js` (RBAC_PERMISSIONS)
- Todos os usuários com same ROLE têm acesso ao mesmo lugar

### 2️⃣ Nível MÓDULO (Granular)
- Controla acesso **por usuário individual**
- Definido em: Tabela `usuarios_modulos` (Supabase)
- Configurado em: `/pages/gerenciar-permissoes.html`
- Arquivo: `js/permissoes.js` - classe PermissaoManager

## ✅ COMO ADICIONAR PERMISSÕES GRANULARES A UMA PÁGINA

### Passo 1: Adicionar ao Mapeamento (js/auth-rbac.js)
```javascript
const PAGE_TO_MODULE_SLUG = {
    'minha-pagina.html': 'slug-do-modulo',
    // ... outras páginas
};
```

### Passo 2: Importar o arquivo permissoes.js na página
```html
<script src="../js/permissoes.js"></script>
```

### Passo 3: Chamar protectPageAccess() no início da página
```html
<script>
(async () => {
    await checkAuth();
    await protectPageAccess();  // ✅ Esta função agora verifica AMBOS os níveis
    // ... resto do código
})();
</script>
```

## 🔍 COMO VERIFICAR PERMISSÃO PARA UMA AÇÃO

```javascript
// Verificar se pode acessar um módulo
const pode = await permissaoManager.podeAcessarModulo('pdv');

// Verificar se pode criar (ação específica)
const podeCriar = await permissaoManager.podeEditar('produtos');

// Verificar se pode deletar
const podeDeletar = await permissaoManager.podeEditar('usuarios');

// Obter lista de módulos disponíveis
const modulos = await permissaoManager.obterModulosDisponiveis();
```

## 📋 PÁGINAS JÁ COM PERMISSÕES GRANULARES

- ✅ `pdv.html` - Importa permissoes.js
- ✅ `gerenciar-permissoes.html` - Importa permissoes.js
- ✅ `configuracoes-empresa.html` - Importa permissoes.js

## 🚨 PASSO IMPORTANTE: Criar módulos na tabela `modulos`

Antes que as permissões funcionem, você precisa criar os módulos no Supabase.

Execute este SQL:

```sql
INSERT INTO public.modulos (nome, slug, descricao, icone) VALUES
('PDV', 'pdv', 'Ponto de venda', 'fa-shopping-cart'),
('Produtos', 'produtos', 'Gerenciar produtos', 'fa-box'),
('Vendas', 'vendas', 'Controle de vendas', 'fa-receipt'),
('Estoque', 'estoque', 'Gerenciar estoque', 'fa-warehouse'),
('Pedidos de Compra', 'pedidos-compra', 'Pedidos para fornecedores', 'fa-file-invoice'),
('Clientes', 'clientes', 'Gerenciar clientes', 'fa-users'),
('Fornecedores', 'fornecedores', 'Gerenciar fornecedores', 'fa-building'),
('Usuários', 'usuarios', 'Gerenciar usuários', 'fa-user-secret'),
('Configurações', 'configuracoes', 'Configurações da empresa', 'fa-cogs');
```

Depois, vá a `/pages/gerenciar-permissoes.html` e configure as permissões para cada usuário!

## 🔧 FLUXO COMPLETO

1. Admin acessa `/pages/gerenciar-permissoes.html`
2. Seleciona um usuário
3. Marca quais módulos o usuário pode acessar
4. Define ações específicas (criar, editar, deletar)
5. Clica em "Salvar"
6. Usuário tenta acessar página
7. Sistema verifica:
   - ✅ Sessão válida?
   - ✅ ROLE tem acesso?
   - ✅ Módulo foi liberado em gerenciar-permissões?
8. Se OK → Permite acesso ✅
9. Se não → Redireciona com mensagem de erro ❌
