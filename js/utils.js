// =====================================================
// FUNÇÕES UTILITÁRIAS
// =====================================================

// Mostrar mensagem toast
function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `fixed top-4 right-4 px-6 py-3 rounded-lg shadow-lg text-white z-50 animate-fade-in ${
        type === 'success' ? 'bg-green-500' :
        type === 'error' ? 'bg-red-500' :
        type === 'warning' ? 'bg-yellow-500' :
        'bg-blue-500'
    }`;
    toast.textContent = message;
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.classList.add('animate-fade-out');
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// Contador de operações ativas para evitar fechar loading prematuramente
let activeLoadingOperations = 0;

// Mostrar loading com controle de operações simultâneas
function showLoading(show = true, operationId = null) {
    const loadingEl = document.getElementById('loading');
    if (!loadingEl) return;
    
    if (show) {
        activeLoadingOperations++;
        loadingEl.classList.remove('hidden');
        // Garantir que o body não tenha scroll quando loading estiver ativo
        document.body.style.overflow = 'hidden';
    } else {
        activeLoadingOperations = Math.max(0, activeLoadingOperations - 1);
        
        // Só esconde o loading quando não houver mais operações ativas
        if (activeLoadingOperations === 0) {
            loadingEl.classList.add('hidden');
            document.body.style.overflow = 'auto';
        }
    }
}

// Função para garantir que o loading seja sempre ocultado (uso em catch/finally)
function hideLoading() {
    activeLoadingOperations = 0;
    const loadingEl = document.getElementById('loading');
    if (loadingEl) {
        loadingEl.classList.add('hidden');
        document.body.style.overflow = 'auto';
    }
}

// Wrapper para executar operação com loading automático
async function withLoading(operation, errorMessage = 'Erro ao executar operação') {
    showLoading(true);
    try {
        return await operation();
    } catch (error) {
        console.error(errorMessage, error);
        showToast(error.message || errorMessage, 'error');
        throw error;
    } finally {
        showLoading(false);
    }
}

// Formatar moeda
function formatCurrency(value) {
    return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL'
    }).format(value);
}

// Formatar data
function formatDate(date) {
    return new Intl.DateTimeFormat('pt-BR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
    }).format(new Date(date));
}

// Formatar data e hora
function formatDateTime(date) {
    return new Intl.DateTimeFormat('pt-BR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    }).format(new Date(date));
}

// Formatar CNPJ
function formatCNPJ(cnpj) {
    return cnpj.replace(/^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5');
}

// Validar email
function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

// Validar CNPJ
function validateCNPJ(cnpj) {
    cnpj = cnpj.replace(/[^\d]/g, '');
    return cnpj.length === 14;
}

// Gerar número de pedido
function generateOrderNumber(tipo = 'COMPRA') {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const random = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
    const prefix = tipo === 'VENDA' ? 'VND' : 'PED';
    return `${prefix}${year}${month}${day}${random}`;
}

// Gerar link WhatsApp
function generateWhatsAppLink(phone, message) {
    const cleanPhone = phone.replace(/\D/g, '');
    const encodedMessage = encodeURIComponent(message);
    return `https://wa.me/${cleanPhone}?text=${encodedMessage}`;
}

// Confirmar ação
async function confirmAction(message) {
    return confirm(message);
}

// Obter parâmetro da URL
function getUrlParameter(name) {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(name);
}

// Redirecionar
function redirect(url) {
    window.location.href = url;
}

// Verificar se está autenticado
async function checkAuth() {
    try {
        // Garantir que o Supabase está pronto antes de usar
        if (!window.supabase || typeof window.supabase.auth !== 'object') {
            console.warn('⏳ Supabase não inicializado ainda, aguardando...');
            if (typeof aguardarClientePronto === 'function') {
                await aguardarClientePronto();
            } else {
                // Fallback: aguardar um pouco
                await new Promise(r => setTimeout(r, 500));
            }
        }

        if (!window.supabase) {
            console.warn('❌ Supabase indisponível após aguardar');
            redirect('/index.html');
            return null;
        }

        // Apenas verificar se há sessão válida
        // NÃO fazer nenhuma query ao banco - isso está causando erro 406
        const { data: { session }, error: sessionError } = await window.supabase.auth.getSession();
        
        if (sessionError) {
            console.warn('⚠️ Erro ao obter sessão:', sessionError.message);
            redirect('/index.html');
            return null;
        }

        if (!session) {
            console.log('⏳ Sem sessão ativa');
            redirect('/index.html');
            return null;
        }

        console.log('✅ Sessão válida para:', session.user.email);
        
        // ⚡ IMPORTANTE: Se usuário existe em auth mas não em public.users, criar automaticamente
        // Isso resolve problema de usuários "órfãos" em auth.users sem registro em public.users
        try {
            // Verificar se usuário existe em public.users (usando maybeSingle para não errar)
            const { data: userExists, error: checkError } = await window.supabase
                .from('users')
                .select('id')
                .eq('id', session.user.id)
                .maybeSingle();
            
            // Se usuário não existe, criar automaticamente
            if (!userExists && !checkError) {
                console.log('⚠️ Usuário existe em Auth mas não em public.users, criando automaticamente...');
                await window.supabase
                    .from('users')
                    .insert([{
                        id: session.user.id,
                        email: session.user.email,
                        full_name: session.user.user_metadata?.full_name || session.user.email.split('@')[0],
                        nome_completo: session.user.user_metadata?.full_name || session.user.email.split('@')[0],
                        role: 'ESTOQUISTA',  // role padrão
                        ativo: false,
                        email_confirmado: false,
                        approved: false
                    }]);
                console.log('✅ Registro de usuário criado automaticamente');
            }
        } catch (syncError) {
            // Não bloqueia login se não conseguir sincronizar
            console.warn('⚠️ Não conseguiu sincronizar usuário (continuando):', syncError.message);
        }
        
        return session;

    } catch (error) {
        console.error('❌ Erro em checkAuth:', error.message);
        // Em qualquer erro, redirecionar para login
        redirect('/index.html');
        return null;
    }
}

// Obter usuário atual
async function getCurrentUser() {
    try {
        // Garantir que o Supabase está pronto
        if (!window.supabase || typeof window.supabase.from !== 'function') {
            console.warn('Supabase não inicializado para getCurrentUser, aguardando...');
            if (typeof aguardarClientePronto === 'function') {
                await aguardarClientePronto();
            } else {
                await new Promise(r => setTimeout(r, 500));
            }
        }

        if (!window.supabase || typeof window.supabase.from !== 'function') {
            console.warn('Supabase indisponível após aguardar em getCurrentUser');
            return null;
        }

        const { data: { session } } = await window.supabase.auth.getSession();
        if (!session) return null;

        const { data: users, error } = await window.supabase
            .from('users')
            .select('*')
            .eq('id', session.user.id)
            .limit(1);

        if (error) {
            console.error('Erro ao buscar usuário:', error);
            return null;
        }

        // Retornar primeiro usuário ou null se não houver
        const user = users && users.length > 0 ? users[0] : null;
        
        if (!user) {
            console.warn('⚠️ Usuário autenticado mas não encontrado na tabela users. ID:', session.user.id);
            // Retornar usuário com role VENDEDOR (padrão) em vez de null
            return {
                id: session.user.id,
                email: session.user.email,
                full_name: session.user.user_metadata?.full_name || 'Usuário',
                role: 'VENDEDOR',  // Role padrão
                ativo: true
            };
        }

        return user;
    } catch (storageError) {
        console.warn('Erro de acesso ao storage no getCurrentUser:', storageError);
        // Em contexto restritivo, retornar usuário mock com VENDEDOR
        return {
            id: 'mock-user',
            email: 'usuario@sistema.com',
            full_name: 'Usuário do Sistema',
            role: 'VENDEDOR',
            ativo: true
        };
    }
}

// Verificar permissão
async function hasRole(roles) {
    const user = await getCurrentUser();
    if (!user) return false;
    
    // Normalizar role do usuário
    const normalizedUserRole = user.role?.toUpperCase() === 'ADMINISTRADOR' ? 'ADMIN' : user.role?.toUpperCase();
    
    if (Array.isArray(roles)) {
        return roles.map(r => r?.toUpperCase() === 'ADMINISTRADOR' ? 'ADMIN' : r?.toUpperCase()).includes(normalizedUserRole);
    }
    
    const normalizedCheckRole = roles?.toUpperCase() === 'ADMINISTRADOR' ? 'ADMIN' : roles?.toUpperCase();
    return normalizedUserRole === normalizedCheckRole;
}

// Obter badge de status
function getStatusBadge(status) {
    const badges = {
        'RASCUNHO': '<span class="px-2 py-1 text-xs rounded-full bg-gray-200 text-gray-800">Rascunho</span>',
        'ENVIADO': '<span class="px-2 py-1 text-xs rounded-full bg-blue-200 text-blue-800">Enviado</span>',
        'APROVADO': '<span class="px-2 py-1 text-xs rounded-full bg-green-200 text-green-800">Aprovado</span>',
        'REJEITADO': '<span class="px-2 py-1 text-xs rounded-full bg-red-200 text-red-800">Rejeitado</span>',
        'FINALIZADO': '<span class="px-2 py-1 text-xs rounded-full bg-purple-200 text-purple-800">Finalizado</span>',
        'CANCELADO': '<span class="px-2 py-1 text-xs rounded-full bg-red-300 text-red-900">Cancelado</span>',
        'SEPARADO': '<span class="px-2 py-1 text-xs rounded-full bg-indigo-200 text-indigo-800">Separado</span>',
        'DESPACHADO': '<span class="px-2 py-1 text-xs rounded-full bg-teal-200 text-teal-800">Despachado</span>',
        
        // Status de envio (logística)
        'AGUARDANDO_SEPARACAO': '<span class="px-2 py-1 text-xs rounded-full bg-yellow-200 text-yellow-800">Aguardando Separação</span>'
    };
    return badges[status] || status;
}

// Debounce para search
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Download CSV
function downloadCSV(data, filename) {
    const csv = convertToCSV(data);
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', filename);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

function convertToCSV(data) {
    if (data.length === 0) return '';
    
    const headers = Object.keys(data[0]);
    const csvRows = [];
    
    csvRows.push(headers.join(','));
    
    for (const row of data) {
        const values = headers.map(header => {
            const escaped = ('' + row[header]).replace(/"/g, '\\"');
            return `"${escaped}"`;
        });
        csvRows.push(values.join(','));
    }
    
    return csvRows.join('\n');
}

// Handle de erros
function handleError(error, customMessage = 'Ocorreu um erro') {
    console.error('Error:', error);
    
    // Traduzir erros comuns para português
    let errorMessage = error.message || error;
    
    // Email duplicado
    if (errorMessage.includes('duplicate key value violates unique constraint "users_email_key"') ||
        errorMessage.includes('users_email_key') ||
        errorMessage.includes('duplicate key')) {
        showToast('Este email já está cadastrado no sistema. Use outro email ou faça login.', 'error');
        return;
    }
    
    // Email já registrado (Supabase auth)
    if (errorMessage.includes('User already registered') || 
        errorMessage.includes('already registered')) {
        showToast('Este email já está cadastrado. Faça login ou use a opção "Esqueci minha senha".', 'error');
        return;
    }
    
    // Email inválido
    if (errorMessage.includes('Invalid email') || 
        errorMessage.includes('invalid email')) {
        showToast('Email inválido. Verifique o formato do email.', 'error');
        return;
    }
    
    // Senha fraca
    if (errorMessage.includes('Password should be at least') ||
        errorMessage.includes('password')) {
        showToast('Senha muito fraca. Use no mínimo 6 caracteres.', 'error');
        return;
    }
    
    // Credenciais inválidas
    if (errorMessage.includes('Invalid login credentials') ||
        errorMessage.includes('invalid credentials')) {
        showToast('Email ou senha incorretos. Verifique suas credenciais.', 'error');
        return;
    }
    
    // Email não confirmado - REMOVIDO (não precisa mais confirmar email)
    // if (errorMessage.includes('Email not confirmed') ||
    //     errorMessage.includes('not confirmed')) {
    //     showToast('Email não confirmado. Verifique sua caixa de entrada e clique no link de confirmação.', 'error');
    //     return;
    // }
    
    // Usuário não encontrado
    if (errorMessage.includes('User not found')) {
        showToast('Usuário não encontrado. Verifique o email digitado.', 'error');
        return;
    }
    
    // RLS policy violation
    if (errorMessage.includes('new row violates row-level security policy') ||
        errorMessage.includes('row-level security')) {
        showToast('Você não tem permissão para realizar esta ação.', 'error');
        return;
    }
    
    // Foreign key violation
    if (errorMessage.includes('violates foreign key constraint')) {
        showToast('Não é possível excluir este registro pois está sendo usado em outro lugar.', 'error');
        return;
    }

    // Categoria duplicada
    if (errorMessage.includes('categorias_nome_key') || 
        (errorMessage.includes('duplicate key') && errorMessage.includes('nome'))) {
        showToast('❌ Esta categoria já existe no sistema. Use um nome diferente.', 'error');
        return;
    }

    // Produto duplicado
    if (errorMessage.includes('produtos_nome_key') || 
        (errorMessage.includes('duplicate key') && errorMessage.includes('produtos'))) {
        showToast('❌ Este produto já existe no sistema. Use um nome diferente.', 'error');
        return;
    }

    // Marca duplicada
    if (errorMessage.includes('marcas_nome_key') || 
        (errorMessage.includes('duplicate key') && errorMessage.includes('marcas'))) {
        showToast('❌ Esta marca já existe no sistema. Use um nome diferente.', 'error');
        return;
    }

    // Network error
    if (errorMessage.includes('Failed to fetch') ||
        errorMessage.includes('NetworkError')) {
        showToast('Erro de conexão. Verifique sua internet e tente novamente.', 'error');
        return;
    }
    
    // Mensagem padrão com tradução
    showToast(customMessage + ': ' + errorMessage, 'error');
}

// =====================================================
// CONFIGURAÇÕES DA EMPRESA (para uso global)
// =====================================================

/**
 * Buscar configurações da empresa (função global)
 * Funciona com ou sem autenticação (permitido em página de login)
 */
async function getEmpresaConfig() {
    try {
        // Verificar se supabase está COMPLETAMENTE disponível
        if (!window.supabase || typeof window.supabase.from !== 'function') {
            console.warn('⚠️ Supabase.from não disponível para getEmpresaConfig');
            return null;
        }

        // Envolver em try-catch porque supabase.auth.getSession() 
        // pode tentar acessar storage em alguns contextos
        try {
            const { data, error } = await window.supabase
                .from('empresa_config')
                .select('*')
                .limit(1);

            if (error) {
                // Se for erro de permissão (42501), retornar null silenciosamente
                if (error.code === '42501') {
                    console.warn('Tabela empresa_config requer política de leitura pública. Verifique as policies RLS.');
                    return null;
                }
                throw error;
            }
            return data && data.length > 0 ? data[0] : null;
        } catch (queryError) {
            // Se for erro de acesso ao storage, apenas retornar null
            if (queryError.message?.includes('Access to storage')) {
                console.warn('Não foi possível acessar storage para empresa_config');
                return null;
            }
            throw queryError;
        }
    } catch (error) {
        console.error('Erro ao buscar configurações da empresa:', error);
        return null;
    }
}

// =====================================================
// MÁSCARAS DE FORMATAÇÃO
// =====================================================

// Aplicar máscara de CPF: 000.000.000-00
function maskCPF(value) {
    value = value.replace(/\D/g, '');
    value = value.replace(/(\d{3})(\d)/, '$1.$2');
    value = value.replace(/(\d{3})(\d)/, '$1.$2');
    value = value.replace(/(\d{3})(\d{1,2})$/, '$1-$2');
    return value.substring(0, 14);
}

// Aplicar máscara de CNPJ: 00.000.000/0000-00
function maskCNPJ(value) {
    value = value.replace(/\D/g, '');
    value = value.replace(/^(\d{2})(\d)/, '$1.$2');
    value = value.replace(/^(\d{2})\.(\d{3})(\d)/, '$1.$2.$3');
    value = value.replace(/\.(\d{3})(\d)/, '.$1/$2');
    value = value.replace(/(\d{4})(\d)/, '$1-$2');
    return value.substring(0, 18);
}

// Aplicar máscara de CPF ou CNPJ automaticamente
function maskCPFCNPJ(value) {
    value = value.replace(/\D/g, '');
    if (value.length <= 11) {
        return maskCPF(value);
    } else {
        return maskCNPJ(value);
    }
}

// Aplicar máscara de WhatsApp: +55 (00) 00000-0000
function maskWhatsApp(value) {
    // Remove tudo que não é dígito
    value = value.replace(/\D/g, '');
    
    // Se não começar com 55, adiciona
    if (!value.startsWith('55') && value.length > 0) {
        value = '55' + value;
    }
    
    // Limita a 13 dígitos (55 + 2 DDD + 9 número)
    value = value.substring(0, 13);
    
    // Aplica a máscara progressivamente
    let formatted = '';
    
    if (value.length >= 2) {
        // +55
        formatted = '+' + value.substring(0, 2);
    }
    
    if (value.length > 2) {
        // +55 (XX
        formatted += ' (' + value.substring(2, 4);
    }
    
    if (value.length > 4) {
        // +55 (XX) 
        formatted += ') ' + value.substring(4, 9);
    }
    
    if (value.length > 9) {
        // +55 (XX) XXXXX-XXXX
        formatted += '-' + value.substring(9, 13);
    }
    
    return formatted || value;
}

// Remover máscara e retornar apenas números
function unmask(value) {
    return value ? value.replace(/\D/g, '') : '';
}

// Inicializar máscaras em um input
function applyMask(inputId, maskType) {
    const input = document.getElementById(inputId);
    if (!input) return;

    input.addEventListener('input', (e) => {
        let value = e.target.value;
        
        switch(maskType) {
            case 'cpf':
                e.target.value = maskCPF(value);
                break;
            case 'cnpj':
                e.target.value = maskCNPJ(value);
                break;
            case 'cpf-cnpj':
                e.target.value = maskCPFCNPJ(value);
                break;
            case 'whatsapp':
                e.target.value = maskWhatsApp(value);
                break;
        }
    });

    // Aplicar máscara ao carregar se já houver valor
    if (input.value) {
        const event = new Event('input', { bubbles: true });
        input.dispatchEvent(event);
    }
}
