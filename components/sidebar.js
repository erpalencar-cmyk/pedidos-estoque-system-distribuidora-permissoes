// =====================================================
// COMPONENTE: SIDEBAR
// Cada link possui data-modulo="slug" para controle dinâmico de permissões
// =====================================================

function createSidebar() {
    return `
        <style id="sidebar-cloak">
            /* Esconder links do sidebar até permissões carregarem — evita flash */
            .sidebar-link[data-modulo]:not([data-modulo="dashboard"]) { display: none !important; }
            .sidebar-section { display: none !important; }
        </style>
        <aside id="sidebar" class="sidebar fixed top-16 left-0 h-full w-64 bg-gray-800 text-white z-30 overflow-y-auto pb-20">
            <nav class="mt-5 px-2">
                <a href="/pages/dashboard.html" data-modulo="dashboard" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition mb-1">
                    <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
                    </svg>
                    Dashboard
                </a>

                <div class="mt-6 sidebar-section">
                    <h3 class="px-4 text-xs font-semibold text-gray-400 uppercase tracking-wider">Cadastros</h3>
                    
                    <a href="/pages/produtos.html" id="menu-produtos" data-modulo="produtos" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition mt-1">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"></path>
                        </svg>
                        Produtos
                    </a>

                    <a href="/pages/fornecedores.html" id="menu-fornecedores" data-modulo="fornecedores" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
                        </svg>
                        Fornecedores
                    </a>

                    <a href="/pages/clientes.html" id="menu-clientes" data-modulo="clientes" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
                        </svg>
                        Clientes
                    </a>

                    <a href="/pages/usuarios.html" id="menu-usuarios" data-modulo="usuarios" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path>
                        </svg>
                        Usuários
                    </a>

                    <a href="/pages/gerenciar-permissoes.html" id="menu-gerenciar-permissoes" data-modulo="gerenciar-permissoes" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                        </svg>
                        Gerenciar Permissões
                    </a>

                    <a href="/pages/caixas.html" id="menu-caixas" data-modulo="caixas" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"></path>
                        </svg>
                        Caixas
                    </a>

                    <a href="/pages/aprovacao-usuarios.html" id="menu-aprovacao-usuarios" data-modulo="aprovacao-usuarios" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                        </svg>
                        Aprovações de Usuários
                    </a>

                    <a href="/pages/configuracoes-empresa.html" id="menu-config-empresa" data-modulo="configuracoes-empresa" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                        </svg>
                        Configurações da Empresa
                    </a>
                </div>

                <div class="mt-6 sidebar-section">
                    <h3 class="px-4 text-xs font-semibold text-gray-400 uppercase tracking-wider">Vendas</h3>
                    
                    <a href="/pages/pdv.html" id="menu-pdv" data-modulo="pdv" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md bg-green-600 hover:bg-green-700 transition mt-1">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
                        </svg>
                        <span class="font-semibold">PDV - Caixa</span>
                    </a>

                    <a href="/pages/comandas.html" id="menu-comandas" data-modulo="comandas" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md bg-orange-600 hover:bg-orange-700 transition mt-2">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                        </svg>
                        <span class="font-semibold">Comandas</span>
                        <span id="badge-comandas" class="hidden ml-2 px-2 py-1 text-xs font-semibold rounded-full bg-white text-orange-600"></span>
                    </a>
                </div>

                <div class="mt-6 sidebar-section">
                    <h3 class="px-4 text-xs font-semibold text-gray-400 uppercase tracking-wider">Operações</h3>
                    
                    <a href="/pages/estoque.html" id="menu-estoque" data-modulo="estoque" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition mt-1">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4"></path>
                        </svg>
                        Estoque
                    </a>

                    <a href="/pages/controle-validade.html" id="menu-controle-validade" data-modulo="controle-validade" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                        </svg>
                        <span class="flex-1">Controle de Validade</span>
                        <span id="badge-vencimentos" class="hidden ml-2 px-2 py-1 text-xs font-semibold rounded-full bg-red-500 text-white"></span>
                    </a>

                    <a href="/pages/pedidos.html" id="menu-compras" data-modulo="pedidos" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"></path>
                        </svg>
                        Pedidos de Compra
                    </a>

                    <a href="/pages/vendas.html" id="menu-vendas" data-modulo="vendas" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"></path>
                        </svg>
                        Vendas
                    </a>

                    <a href="/pages/vendas-pendentes.html" id="menu-vendas-pendentes" data-modulo="vendas-pendentes" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                        <span class="flex-1">Vendas Pendentes</span>
                        <span id="badge-pendentes" class="hidden ml-2 px-2 py-1 text-xs font-semibold rounded-full bg-orange-500 text-white"></span>
                    </a>

                    <a href="/pages/conferencia-vendas.html" id="menu-conferencia" data-modulo="conferencia-vendas" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"></path>
                        </svg>
                        <span class="flex-1">Conferência de Vendas</span>
                        <span id="badge-conferencia" class="hidden ml-2 px-2 py-1 text-xs font-semibold rounded-full bg-blue-500 text-white"></span>
                    </a>

                    <a href="/pages/aprovacao.html" id="menu-aprovacao" data-modulo="aprovacao" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                        Aprovações
                    </a>

                    <a href="/pages/pre-pedidos.html" id="menu-pre-pedidos" data-modulo="pre-pedidos" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"></path>
                        </svg>
                        <span class="flex-1">Pré-Pedidos Públicos</span>
                        <span id="badge-pre-pedidos" class="hidden ml-2 px-2 py-1 text-xs font-semibold rounded-full bg-purple-500 text-white"></span>
                    </a>

                </div>

                <div class="mt-6 sidebar-section">
                    <h3 class="px-4 text-xs font-semibold text-gray-400 uppercase tracking-wider">Financeiro</h3>
                    
                    <a href="/pages/contas-pagar.html" id="menu-contas-pagar" data-modulo="contas-pagar" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition mt-1">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"></path>
                        </svg>
                        <span class="flex-1">Contas a Pagar</span>
                        <span id="badge-contas-pagar" class="hidden ml-2 px-2 py-1 text-xs font-semibold rounded-full bg-red-500 text-white"></span>
                    </a>

                    <a href="/pages/contas-receber.html" id="menu-contas-receber" data-modulo="contas-receber" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                        <span class="flex-1">Contas a Receber</span>
                        <span id="badge-contas-receber" class="hidden ml-2 px-2 py-1 text-xs font-semibold rounded-full bg-blue-500 text-white"></span>
                    </a>

                    <a href="/pages/analise-financeira.html" id="menu-analise-financeira" data-modulo="analise-financeira" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                        </svg>
                        Análise Financeira
                    </a>
                </div>

                <div class="mt-6 sidebar-section">
                    <h3 class="px-4 text-xs font-semibold text-gray-400 uppercase tracking-wider">Fiscal</h3>
                    
                    <a href="/pages/documentos-fiscais.html" id="menu-documentos-fiscais" data-modulo="documentos-fiscais" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition mt-1">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                        </svg>
                        Documentos Fiscais
                    </a>

                    <a href="/pages/distribuicao-nfce.html" id="menu-distribuicao-nfce" data-modulo="distribuicao-nfce" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10"></path>
                        </svg>
                        Distribuição de NFC-e
                    </a>

                    <a href="/pages/teste-focus-nfe.html" id="menu-teste-focus" data-modulo="teste-focus-nfe" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"></path>
                        </svg>
                        Testes Focus NFe
                    </a>

                    <a href="/pages/teste-nuvem-fiscal.html" id="menu-teste-nuvem" data-modulo="teste-nuvem-fiscal" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z"></path>
                        </svg>
                        Testes Nuvem Fiscal
                    </a>
                </div>

                <div class="mt-6 pb-8 sidebar-section">
                    <h3 class="px-4 text-xs font-semibold text-gray-400 uppercase tracking-wider">Sistema</h3>
                    
                    <a href="/pages/reprocessar-estoque.html" id="menu-reprocessar-estoque" data-modulo="reprocessar-estoque" class="sidebar-link group flex items-center px-4 py-3 text-sm font-medium rounded-md hover:bg-gray-700 transition mt-1">
                        <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                        </svg>
                        Reprocessar Estoque
                    </a>
                </div>
            </nav>
        </aside>
    `;
}

// =====================================================
// Módulos exclusivos de ADMIN (nunca visíveis p/ outros)
// =====================================================
const ADMIN_ONLY_MODULES = [
    'usuarios',
    'gerenciar-permissoes',
    'aprovacao-usuarios',
    'teste-focus-nfe',
    'teste-nuvem-fiscal',
    'reprocessar-estoque'
];

// =====================================================
// initSidebar — visibilidade baseada em permissões dinâmicas
// =====================================================
async function initSidebar() {
    // 1. Marcar item ativo
    const currentPage = window.location.pathname;
    document.querySelectorAll('.sidebar-link').forEach(link => {
        if (link.getAttribute('href') && currentPage.includes(link.getAttribute('href'))) {
            link.classList.add('bg-gray-700');
        }
    });

    // 2. Obter usuário
    const user = await getCurrentUser();
    if (!user) {
        removeSidebarCloak();
        return;
    }

    const role = (user.role || '').toUpperCase();
    const isAdmin = role === 'ADMIN' || role === 'ADMINISTRADOR';

    // ADMIN vê tudo — remover cloak e mostrar tudo
    if (isAdmin) {
        removeSidebarCloak();
        setupSidebarMobile();
        return;
    }

    // 3. Buscar slugs de módulos permitidos do banco de dados
    let permittedSlugs = ['dashboard']; // Dashboard sempre acessível

    try {
        const { data, error } = await window.supabase
            .from('usuarios_modulos')
            .select('modulo_id, modulos(slug)')
            .eq('usuario_id', user.id)
            .eq('pode_acessar', true);

        if (!error && data) {
            const dbSlugs = data
                .map(item => item.modulos?.slug)
                .filter(Boolean);
            permittedSlugs = [...permittedSlugs, ...dbSlugs];
        }
    } catch (err) {
        console.warn('⚠️ Erro ao carregar permissões do sidebar:', err);
    }

    // 4. Mostrar itens com permissão, manter ocultos os sem permissão
    document.querySelectorAll('.sidebar-link[data-modulo]').forEach(link => {
        const modulo = link.getAttribute('data-modulo');
        if (!modulo || modulo === 'dashboard') return; // Dashboard sempre visível

        // Módulos exclusivos de admin — manter ocultos para não-admin
        if (ADMIN_ONLY_MODULES.includes(modulo)) {
            link.style.display = 'none';
            return;
        }

        // Mostrar se tem permissão, esconder se não
        if (permittedSlugs.includes(modulo)) {
            link.style.display = ''; // Mostrar
        } else {
            link.style.display = 'none';
        }
    });

    // 5. Mostrar seções que têm pelo menos um link visível
    document.querySelectorAll('.sidebar-section').forEach(section => {
        const visibleLinks = section.querySelectorAll('a.sidebar-link:not([style*="display: none"])');
        if (visibleLinks.length > 0) {
            section.style.display = ''; // Mostrar seção
        } else {
            section.style.display = 'none';
        }
    });

    // 6. Remover cloak — agora links corretos estão visíveis
    removeSidebarCloak();

    // 7. Mobile
    setupSidebarMobile();
}

/**
 * Remover o style cloak que esconde links durante carregamento
 */
function removeSidebarCloak() {
    const cloak = document.getElementById('sidebar-cloak');
    if (cloak) cloak.remove();
}

// Lógica de fechar sidebar ao clicar fora (mobile)
function setupSidebarMobile() {
    document.addEventListener('click', (e) => {
        const sidebar = document.getElementById('sidebar');
        const sidebarToggle = document.getElementById('sidebar-toggle');
        
        if (sidebar && sidebarToggle && 
            !sidebar.contains(e.target) && 
            !sidebarToggle.contains(e.target) &&
            sidebar.classList.contains('active')) {
            sidebar.classList.remove('active');
        }
    });
}

// Função auxiliar para esconder múltiplos itens do menu (mantida para compatibilidade)
function hideMenuItems(menuIds) {
    menuIds.forEach(id => {
        const menuItem = document.getElementById(id);
        if (menuItem) {
            menuItem.style.display = 'none';
        }
    });
}
