# 🔧 INSTRUÇÕES PARA CORRIGIR O SISTEMA DE PERMISSÕES

## 📋 PROBLEMAS IDENTIFICADOS
1. ❌ `empresa_id` não existe na tabela `usuarios_modulos`
2. ❌ RLS policies bloqueando queries com erro 406
3. ❌ Módulos não estão inseridos na tabela `modulos`
4. ❌ Sidebar mostrava todos os módulos mesmo sem permissão

## ✅ SOLUÇÕES IMPLEMENTADAS

### 1. Código JavaScript Corrigido ✅
- `js/permissoes.js`: Removido TODO `empresa_id` das queries
- `js/permissoes.js`: Fallback agora é **RESTRITIVO** (deny by default)
- `js/permissoes.js`: Query simplificada para apenas `usuario_id` e `modulo_id`

### 2. SQL para Executar no Supabase

Você PRECISA executar 2 scripts SQL no Supabase:

---

## 🚀 PASSO 1: Executar CORRIGIR_RLS_SIMPLES.sql

**Localização**: `database/CORRIGIR_RLS_SIMPLES.sql`

**O que faz**:
- Remove todas as políticas RLS antigas
- Habilita RLS nas tabelas
- Cria políticas SIMPLES E PERMISSIVAS (sem erro 406)
- Essencial para PermissaoManager funcionar

**Como fazer**:
1. Acesse https://app.supabase.com
2. Selecione seu projeto (uyyyxblwffzonczrtqjy)
3. Vá em: **SQL Editor** → **New Query**
4. Copie TODO conteúdo do arquivo `database/CORRIGIR_RLS_SIMPLES.sql`
5. Cole no SQL Editor
6. Clique em **Run** (Ctrl+Enter)
7. Verifique se não há erros

**Resultado esperado**: Você deve ver as políticas criadas para as tabelas users, usuarios_modulos, modulos, etc.

---

## 🚀 PASSO 2: Executar INSERIR_MODULOS.sql

**Localização**: `database/INSERIR_MODULOS.sql`

**O que faz**:
- Insere TODOS os 14 módulos do sistema
- Sem duplicatas (usa ON CONFLICT)
- Inclui: PDV, Produtos, Estoque, Vendas, Fornecedores, Clientes, Caixas, Contas, Usuários, Permissões, Configurações

**Como fazer**:
1. No mesmo SQL Editor
2. Copie TODO conteúdo do arquivo `database/INSERIR_MODULOS.sql`
3. Cole
4. Clique em **Run**
5. Verifique se inseriu 14 módulos

**Resultado esperado**:
```
14 rows inserted into modulos
```

---

## 📊 PASSO 3: Verificar Dados Inseridos

Você pode verificar se funcionou rodando no SQL Editor:

```sql
-- Ver todos os módulos
SELECT id, nome, slug FROM modulos ORDER BY ordem;

-- Contar quantos módulos
SELECT COUNT(*) FROM modulos;

-- Ver políticas RLS
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE tablename IN ('users', 'usuarios_modulos', 'modulos')
ORDER BY tablename;
```

---

## ⚙️ PASSO 4: Configurar Permissões de Usuários (Opcional agora)

Depois que RLS e módulos estão OK, você pode:

1. Ir em: `/pages/gerenciar-permissoes.html`
2. Selecionar um usuário
3. Marcar quais módulos ele pode acessar
4. Clicar "Salvar"

**Importante**: Se não configurar permissões, o usuário NÃO terá acesso a NENHUM módulo (deny by default ✅)

---

## 🧪 PASSO 5: Testar

1. Faça logout
2. Faça login novamente
3. Abra o Console do navegador (F12)
4. Você deve ver logs como:
   ```
   ✅ PermissaoManager inicializado para: 2c5476d4-...
   ✅ Permissão OK para pdv
   🔒 Acesso negado para usuarios
   ✅ Menu menu-pdv visível
   🔒 Menu menu-usuarios oculto
   ```

5. A **sidebar deve mostrar MENOS módulos agora** (apenas os que têm permissão)

---

## 🔍 VERIFICAÇÃO DE ERROS

Depois feito, você **NÃO deve ver mais**:
❌ `406 (Not Acceptable)`
❌ `column usuarios_modulos.empresa_id does not exist`
❌ `módulo xxx não encontrado`

Você deve ver:
✅ `✅ PermissaoManager inicializado`
✅ `✅ Menu menu-xxx visível`
✅ `🔒 Menu menu-xxx oculto`

---

## 📝 ARQUIVO MODIFICADOS

1. **js/permissoes.js** - Removido empresa_id, fallback restritivo
2. **database/CORRIGIR_RLS_SIMPLES.sql** - NOVO - Políticas simples e permissivas
3. **database/INSERIR_MODULOS.sql** - NOVO - Insert de todos os módulos

---

## 💡 POR QUE ISSO FUNCIONA?

| Problema | Causa | Solução |
|----------|-------|---------|
| Erro 406 | RLS muito restritivo | Políticas permissivas (qualquer autenticado pode ler) |
| Coluna não existe | Schema wrong | Removeito empresa_id, usar apenas usuario_id+modulo_id |
| Módulos não encontrados | Tabela vazia | Insert de todos os 14 módulos |
| Mostra tudo | Fallback era permissivo | Fallback agora é DENY BY DEFAULT |

---

## ❓ PRÓXIMAS ETAPAS

1. ✅ Execute os 2 scripts SQL (HOJE)
2. ✅ Verifique se funcionou (logs no console)
3. ✅ Configure permissões em `gerenciar-permissoes.html`
4. ✅ Teste login em novo tab / incógnito
5. ✅ Feche e reabra para verificar cache

---

**Última atualização**: 2026-02-11
**Versão**: Sistema de Permissões v2 (Simplificado)
