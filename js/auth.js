// =====================================================
// AUTENTICAÇÃO
// =====================================================

// Fazer login
async function login(email, password) {
    try {
        showLoading(true);
        
        const { data, error } = await window.supabase.auth.signInWithPassword({
            email,
            password
        });

        if (error) throw error;

        showToast('Login realizado com sucesso!', 'success');
        redirect('/pages/dashboard.html');
        
    } catch (error) {
        handleError(error, 'Erro ao fazer login');
    } finally {
        showLoading(false);
    }
}

// Fazer cadastro
async function register(email, password, fullName, role = 'COMPRADOR', whatsapp = null) {
    try {
        showLoading(true);

        // Criar usuário no auth do Supabase
        const { data: authData, error: authError } = await window.supabase.auth.signUp({
            email,
            password
        });

        if (authError) {
            // Tratar erro específico de email já registrado no Supabase Auth
            if (authError.message.includes('already registered') || 
                authError.message.includes('User already registered')) {
                throw new Error('Este email já está cadastrado. Se você já confirmou o email, faça login. Caso contrário, verifique sua caixa de entrada.');
            }
            throw authError;
        }

        // Criar registro na tabela users (JÁ ATIVO)
        const { error: userError } = await window.supabase
            .from('users')
            .insert([{
                id: authData.user.id,
                email: email,
                full_name: fullName,
                nome_completo: fullName,
                role: role,
                whatsapp: whatsapp,
                ativo: true,
                email_confirmado: true,
                approved: true
            }]);

        if (userError) {
            // Se o usuário já existe na tabela (tentativa de recadastro)
            if (userError.message.includes('duplicate key') || 
                userError.message.includes('users_email_key') ||
                userError.message.includes('users_pkey')) {
                // Usuário já está cadastrado
                console.log('Usuário já existe na tabela users');
            } else {
                // Outro erro, lançar exceção
                throw userError;
            }
        }

        // Mostrar sucesso e redirecionar para login
        showToast('✅ Cadastro realizado com sucesso! Você será redirecionado para login.', 'success');
        setTimeout(() => {
            redirect('../index.html');
        }, 2000);
        
    } catch (error) {
        // Se for erro customizado (mensagem em português), mostrar direto
        if (error.message.includes('já está cadastrado')) {
            showToast(error.message, 'error');
        } else {
            handleError(error, 'Erro ao fazer cadastro');
        }
    } finally {
        showLoading(false);
    }
}

// Fazer logout
async function logout() {
    try {
        // Verificar se há sessão ativa antes de tentar logout
        try {
            const { data: { session } } = await window.supabase.auth.getSession();
            
            if (session) {
                const { error } = await window.supabase.auth.signOut();
                if (error) throw error;
            }
            
            // Limpar qualquer dado local (seguro)
            try {
                // Tentar limpar apenas se storage estiver disponível
                if (typeof localStorage !== 'undefined' && localStorage) {
                    localStorage.clear();
                }
                if (typeof sessionStorage !== 'undefined' && sessionStorage) {
                    sessionStorage.clear();
                }
            } catch (storageError) {
                console.warn('Storage não disponível para limpeza:', storageError.message);
            }
            
            showToast('Logout realizado com sucesso!', 'success');
            redirect('/index.html');
        } catch (storageError) {
            console.warn('Erro de storage no logout:', storageError);
            // Continuar com logout mesmo com erro de storage
            try {
                if (typeof localStorage !== 'undefined' && localStorage) {
                    localStorage.clear();
                }
                if (typeof sessionStorage !== 'undefined' && sessionStorage) {
                    sessionStorage.clear();
                }
            } catch (e) {
                console.warn('Storage não disponível para limpeza:', e.message);
            }
            redirect('/index.html');
        }
        
    } catch (error) {
        // Se for erro de sessão, apenas redirecionar
        if (error.message?.includes('session') || error.message?.includes('Session')) {
            try {
                if (typeof localStorage !== 'undefined' && localStorage) {
                    localStorage.clear();
                }
                if (typeof sessionStorage !== 'undefined' && sessionStorage) {
                    sessionStorage.clear();
                }
            } catch (storageError) {
                console.warn('Storage não disponível para limpeza:', storageError.message);
            }
            redirect('/index.html');
        } else {
            handleError(error, 'Erro ao fazer logout');
        }
    }
}

// Alterar senha
async function changePassword(newPassword) {
    try {
        showLoading(true);

        const { error } = await window.supabase.auth.updateUser({
            password: newPassword
        });

        if (error) throw error;

        showToast('Senha alterada com sucesso!', 'success');
        
    } catch (error) {
        handleError(error, 'Erro ao alterar senha');
    } finally {
        showLoading(false);
    }
}

// Recuperar senha
async function resetPassword(email) {
    try {
        showLoading(true);

        const { error } = await window.supabase.auth.resetPasswordForEmail(email, {
            redirectTo: window.location.origin + '/pages/reset-password.html'
        });

        if (error) throw error;

        showToast('Email de recuperação enviado!', 'success');
        
    } catch (error) {
        handleError(error, 'Erro ao enviar email de recuperação');
    } finally {
        showLoading(false);
    }
}
