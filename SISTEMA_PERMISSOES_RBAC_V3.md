# 🔐 Sistema de Permissões - V3 (RBAC Simples)

## Mudança Crítica: Abandonando Dependência de public.users

### Situação Anterior (V2 - QUEBRADO)
```
❌ Problema: Usuários não propagados em public.users
❌ Sintoma: "Usuário autenticado mas não encontrado na tabela users" (50+ erros)
❌ Resultado: ALL menu items HIDDEN para TODOS
```

### Nova Abordagem (V3 - FUNCIONAL)
```
✅ Estratégia: Ler role DIRETO do Supabase Auth
✅ Verificação: window.supabase.auth.getUser() (confiável)
✅ Resultado: Menus aparecem baseado no ROLE
```

---

## Arquitetura: RBAC (Role-Based Access Control)

### Roles Definidos
| Role | Permissões |
|------|-----------|
| **ADMIN** | Tudo (👑 acesso total) |
| **GERENTE** | Tudo exceto usuarios, aprovacoes, config |
| **VENDEDOR** | vendas, pdv, produtos, estoque, clientes, caixas (padrão) |
| **OPERADOR_CAIXA** | pdv, vendas, caixas, clientes, comandas |
| **ESTOQUISTA** | estoque, produtos, controle-validade, pedidos-compra |
| **COMPRADOR** | estoque, produtos, fornecedores, pedidos-compra, controle-validade |
| **APROVADOR** | pedidos-compra, contas-pagar, vendas, analise-financeira |

---

## Fluxo de Execução

### 1️⃣ User Login
```javascript
// Supabase Auth cria record em auth.users
// Role armazenado em auth user_metadata ou public.users (opcional)
```

### 2️⃣ Sidebar Carrega
```javascript
// components/sidebar.js chama renderizaSidebar()
```

### 3️⃣ PermissaoManager Inicializa
```javascript
// js/permissoes.js → PermissaoManager.inicializar()

// Obtém user do Supabase Auth
const { data: { user: authUser } } = await window.supabase.auth.getUser();

// Lê role de:
// 1. public.users (se user estiver propagado)
// 2. auth user_metadata (fallback)
// 3. Padrão VENDEDOR (último recurso)

this.role = userData?.role || authUser?.user_metadata?.role || 'VENDEDOR';
```

### 4️⃣ Verificação de Permissões
```javascript
// Para cada item do menu
const temPermissao = await permissaoManager.podeAcessarModulo('produtos');

// Se role = VENDEDOR e 'produtos' está em permissoes['VENDEDOR']
// → retorna TRUE → menu visível ✅
// → senão → retorna FALSE → menu oculto 🔒
```

### 5️⃣ Renderização do Menu
```javascript
if (temPermissao) {
    menuItem.style.display = 'block';  // ✅ Mostra
} else {
    menuItem.style.display = 'none';   // 🔒 Esconde
}
```

---

## Mudanças em js/permissoes.js

### ANTES (V2)
```javascript
class PermissaoManager {
    async inicializar() {
        const user = await getCurrentUser();  // ❌ FALHA AQUI
        this.usuarioId = user?.id;
    }
    
    async podeAcessarModulo(slug) {
        // Query de public.users_modulos
        // ❌ Falha porque usuarioId é undefined
    }
}
```

### DEPOIS (V3)
```javascript
class PermissaoManager {
    async inicializar() {
        // ✅ Pega user direto do Auth
        const { data: { user: authUser } } = 
            await window.supabase.auth.getUser();
        
        // ✅ Lê role (com fallbacks)
        this.role = authUser?.user_metadata?.role || 'VENDEDOR';
    }
    
    async podeAcessarModulo(slug) {
        // ✅ Simples: procura slug em permissoes[this.role]
        const modulosPermitidos = permissoes[this.role];
        return modulosPermitidos.includes(slug);
    }
}
```

---

## Benefícios da V3

✅ **Nenhuma dependência em public.users**
   - Funciona mesmo que users não estejam propagados
   - Funciona imediatamente após login

✅ **Sem erros em console**
   - Nenhuma query que possa falhar
   - Role sempre disponível no auth

✅ **Performance melhorada**
   - Permissões calculadas localmente
   - Sem queries ao banco de dados

✅ **Escalável**
   - Pode adicionar próximas camadas (granular)
   - Base sólida para futuros refinamentos

---

## Próximos Passos (Opcional)

### Fase 2: Adicionar Camada Granular
Quando users estiverem propagados corretamente em public.users:

```javascript
async podeAcessarModulo(slug) {
    // Fase 1: Verifica RBAC
    if (!permissoes[this.role].includes(slug)) return false;
    
    // Fase 2: Verifica granular
    const { data } = await window.supabase
        .from('usuarios_modulos')
        .select('pode_acessar')
        .eq('usuario_id', this.usuarioId)
        .eq('modulo', slug)
        .single();
    
    return data?.pode_acessar === true;
}
```

### Fase 2: Administração de Usuários
- Interface para editar roles de usuários
- Página: `/pages/usuarios.html` (já criada)

### Fase 3: Auditoria de Acesso
- Log de quem acessou o quê
- Tabela: `audit_logs`

---

## Testes Recomendados

### ✅ Test 1: Login com ADMIN
```
Resultado esperado: Todos os menus visíveis
```

### ✅ Test 2: Login com VENDEDOR
```
Resultado esperado: Apenas menus de: 
dashboard, pdv, produtos, estoque, vendas, caixas, clientes, controle-validade, comandas
```

### ✅ Test 3: Login com ESTOQUISTA
```
Resultado esperado: Apenas menus de:
dashboard, estoque, produtos, controle-validade, pedidos-compra
```

### ✅ Test 4: Console sem erros
```
Resultado esperado: Nenhum warning de "Usuário autenticado mas não encontrado"
```

---

## Console Logs Esperados (V3)

```
✅ PermissaoManager: Role = VENDEDOR (User: 2c5476d4-...)
✅ VENDEDOR - Acesso OK a dashboard
✅ Menu menu-dashboard VISÍVEL (permissão OK para dashboard)
✅ VENDEDOR - Acesso OK a pdv
✅ Menu menu-pdv VISÍVEL (permissão OK para pdv)
🔒 VENDEDOR - Acesso negado a usuarios
🔒 Menu menu-usuarios oculto (sem permissão para usuarios)
```

---

## Summary

| Aspecto | V2 (Quebrado) | V3 (Funcional) |
|--------|-------------|---------------|
| Dependência | public.users | Auth direto |
| Erros console | 50+ warnings | 0 ❌ |
| Menu visibility | Todos ocultos 🔒 | Baseado em role ✅ |
| Performance | Queries falham | Cálculo local ⚡ |
| Escalabilidade | Bloqueada | Pronta para expansão |

