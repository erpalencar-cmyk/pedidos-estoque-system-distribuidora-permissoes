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

        if (error) {
            // Tratar erro de email não confirmado — orientar admin a desabilitar
            if (error.message?.includes('Email not confirmed') || error.message?.includes('email_not_confirmed')) {
                showToast('⚠️ Email não confirmado. O administrador precisa desabilitar a confirmação de email no Supabase (Auth > Settings > Confirm email = OFF). Enquanto isso, peça ao admin para confirmar seu email manualmente.', 'error');
                showLoading(false);
                return;
            }
            throw error;
        }

        // =====================================================
        // VERIFICAR SE USUÁRIO ESTÁ APROVADO E ATIVO
        // =====================================================
        try {
            // Buscar por ID primeiro, fallback por email
            let userData = null;
            const { data: userById, error: userError } = await window.supabase
                .from('users')
                .select('ativo, approved, role')
                .eq('id', data.user.id)
                .maybeSingle();

            if (userError) {
                console.warn('⚠️ Erro ao verificar status do usuário:', userError.message);
            }

            userData = userById;

            // Fallback: buscar por email se não encontrou por ID
            if (!userData && !userError) {
                const { data: userByEmail } = await window.supabase
                    .from('users')
                    .select('ativo, approved, role')
                    .eq('email', data.user.email)
                    .maybeSingle();
                userData = userByEmail;
            }

            if (userData) {
                // ADMIN sempre pode entrar
                const isAdmin = (userData.role || '').toUpperCase() === 'ADMIN' || 
                                (userData.role || '').toUpperCase() === 'ADMINISTRADOR';

                if (!isAdmin) {
                    if (userData.approved === false) {
                        // Não aprovado — fazer logout e bloquear
                        await window.supabase.auth.signOut();
                        showToast('⏳ Sua conta ainda não foi aprovada pelo administrador. Aguarde a aprovação para acessar o sistema.', 'error');
                        showLoading(false);
                        return;
                    }

                    if (userData.ativo === false) {
                        // Desativado — fazer logout e bloquear
                        await window.supabase.auth.signOut();
                        showToast('🔒 Sua conta está desativada. Entre em contato com o administrador.', 'error');
                        showLoading(false);
                        return;
                    }
                }
            }
        } catch (checkError) {
            console.warn('⚠️ Erro na verificação de aprovação (continuando login):', checkError.message);
        }

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
        // NOTA: Para sistema com aprovação, a confirmação de email deve estar DESABILITADA
        // no Supabase Dashboard (Auth > Settings > Confirm email = OFF)
        const { data: authData, error: authError } = await window.supabase.auth.signUp({
            email,
            password,
            options: {
                data: {
                    full_name: fullName,
                    role: role
                }
            }
        });

        if (authError) {
            // Tratar erro específico de email já registrado no Supabase Auth
            if (authError.message.includes('already registered') || 
                authError.message.includes('User already registered')) {
                throw new Error('Este email já está cadastrado. Faça login ou entre em contato com o administrador.');
            }
            throw authError;
        }

        // Verificar se o signUp retornou um usuário válido
        if (!authData?.user?.id) {
            throw new Error('Erro ao criar conta. Tente novamente.');
        }

        // Criar registro na tabela public.users (INATIVO - aguardando aprovação do admin)
        // email_confirmado = true (não usamos confirmação de email do Supabase, usamos aprovação)
        const { error: userError } = await window.supabase
            .from('users')
            .insert([{
                id: authData.user.id,
                email: email,
                full_name: fullName,
                nome_completo: fullName,
                role: role,
                whatsapp: whatsapp,
                ativo: false,
                email_confirmado: true,
                approved: false
            }]);

        if (userError) {
            // Se o usuário já existe na tabela (tentativa de recadastro)
            if (userError.message.includes('duplicate key') || 
                userError.message.includes('users_email_key') ||
                userError.message.includes('users_pkey')) {
                console.log('Usuário já existe na tabela users');
            } else {
                throw userError;
            }
        }

        // Fazer logout imediato — o usuário não pode acessar o sistema até aprovação
        try {
            await window.supabase.auth.signOut();
        } catch (logoutErr) {
            console.warn('Aviso ao fazer signOut pós-registro:', logoutErr.message);
        }

        // Mostrar sucesso e redirecionar para login
        showToast('✅ Cadastro realizado! Aguarde a aprovação do administrador para acessar o sistema.', 'success');
        setTimeout(() => {
            redirect('../index.html');
        }, 3000);
        
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
