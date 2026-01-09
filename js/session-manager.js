// =====================================================
// GERENCIAMENTO DE SESSÃO E INATIVIDADE
// =====================================================

class SessionManager {
    constructor(options = {}) {
        // Tempo de inatividade em milissegundos (padrão: 15 minutos)
        this.inactivityTimeout = options.inactivityTimeout || 15 * 60 * 1000;
        
        // Tempo de aviso antes do logout (padrão: 2 minutos)
        this.warningTime = options.warningTime || 2 * 60 * 1000;
        
        // Temporizador de inatividade
        this.inactivityTimer = null;
        
        // Temporizador de aviso
        this.warningTimer = null;
        
        // Modal de aviso
        this.warningModal = null;
        
        // Controle de estado
        this.isWarningShown = false;
        this.lastActivity = Date.now();
        
        // Eventos que resetam o temporizador
        this.activityEvents = ['mousedown', 'mousemove', 'keypress', 'scroll', 'touchstart', 'click'];
        
        // Inicializar
        this.init();
    }

    init() {
        console.log('🔒 Session Manager inicializado');
        console.log(`⏰ Timeout de inatividade: ${this.inactivityTimeout / 1000 / 60} minutos`);
        console.log(`⚠️  Aviso antes do logout: ${this.warningTime / 1000 / 60} minutos`);
        
        // Registrar eventos de atividade
        this.registerActivityListeners();
        
        // Iniciar temporizador
        this.resetInactivityTimer();
        
        // Verificar sessão periodicamente (a cada minuto)
        setInterval(() => this.checkSession(), 60 * 1000);
        
        // Verificar se há sessão válida ao iniciar
        this.checkSession();
    }

    registerActivityListeners() {
        this.activityEvents.forEach(event => {
            document.addEventListener(event, () => this.onActivity(), { passive: true });
        });
    }

    onActivity() {
        const now = Date.now();
        
        // Atualizar última atividade
        this.lastActivity = now;
        
        // Se o aviso estiver sendo mostrado, fechá-lo
        if (this.isWarningShown) {
            this.hideWarning();
        }
        
        // Resetar temporizador
        this.resetInactivityTimer();
    }

    resetInactivityTimer() {
        // Limpar temporizadores existentes
        if (this.inactivityTimer) {
            clearTimeout(this.inactivityTimer);
        }
        if (this.warningTimer) {
            clearTimeout(this.warningTimer);
        }

        // Calcular tempo até o aviso
        const timeUntilWarning = this.inactivityTimeout - this.warningTime;
        
        // Agendar aviso
        this.warningTimer = setTimeout(() => {
            this.showWarning();
        }, timeUntilWarning);
        
        // Agendar logout
        this.inactivityTimer = setTimeout(() => {
            this.performLogout('inatividade');
        }, this.inactivityTimeout);
    }

    showWarning() {
        if (this.isWarningShown) return;
        
        this.isWarningShown = true;
        
        // Calcular tempo restante
        const remainingTime = Math.floor(this.warningTime / 1000);
        
        // Criar modal de aviso
        this.warningModal = document.createElement('div');
        this.warningModal.id = 'session-warning-modal';
        this.warningModal.className = 'fixed inset-0 bg-black bg-opacity-70 flex items-center justify-center z-[9999]';
        this.warningModal.innerHTML = `
            <div class="bg-white rounded-lg shadow-2xl max-w-md w-full mx-4 p-8 animate-bounce-in">
                <div class="text-center">
                    <div class="w-20 h-20 bg-yellow-100 rounded-full mx-auto mb-4 flex items-center justify-center animate-pulse">
                        <svg class="w-12 h-12 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                        </svg>
                    </div>
                    
                    <h2 class="text-2xl font-bold text-gray-900 mb-4">⏰ Sessão Expirando!</h2>
                    
                    <div class="bg-yellow-50 border-l-4 border-yellow-500 p-4 mb-6 text-left">
                        <p class="text-yellow-900 font-semibold mb-2">
                            Você está inativo há algum tempo.
                        </p>
                        <p class="text-yellow-800 text-sm">
                            Sua sessão será encerrada automaticamente em:
                        </p>
                        <p id="session-countdown" class="text-3xl font-bold text-yellow-600 mt-3">
                            ${remainingTime}s
                        </p>
                    </div>
                    
                    <div class="bg-blue-50 border-l-4 border-blue-500 p-4 mb-6 text-left">
                        <p class="text-blue-900 text-sm">
                            <strong>💡 Dica:</strong> Clique em "Continuar Trabalhando" para manter sua sessão ativa.
                        </p>
                    </div>
                    
                    <div class="space-y-3">
                        <button 
                            id="session-continue-btn" 
                            class="w-full bg-green-600 text-white py-3 px-4 rounded-lg font-semibold hover:bg-green-700 transition transform hover:scale-105"
                        >
                            ✅ Continuar Trabalhando
                        </button>
                        <button 
                            id="session-logout-btn" 
                            class="w-full bg-gray-200 text-gray-700 py-2 px-4 rounded-lg font-semibold hover:bg-gray-300 transition"
                        >
                            🚪 Sair Agora
                        </button>
                    </div>
                </div>
            </div>
        `;
        
        document.body.appendChild(this.warningModal);
        
        // Adicionar event listeners aos botões
        document.getElementById('session-continue-btn').addEventListener('click', () => {
            this.continueSession();
        });
        
        document.getElementById('session-logout-btn').addEventListener('click', () => {
            this.performLogout('usuario');
        });
        
        // Iniciar contagem regressiva
        this.startCountdown(remainingTime);
        
        // Tocar som de alerta (se disponível)
        this.playAlertSound();
    }

    startCountdown(seconds) {
        let remaining = seconds;
        const countdownEl = document.getElementById('session-countdown');
        
        const interval = setInterval(() => {
            remaining--;
            
            if (countdownEl) {
                countdownEl.textContent = `${remaining}s`;
                
                // Mudar cor quando estiver próximo do fim
                if (remaining <= 30) {
                    countdownEl.classList.add('text-red-600', 'animate-pulse');
                    countdownEl.classList.remove('text-yellow-600');
                }
            }
            
            if (remaining <= 0 || !this.isWarningShown) {
                clearInterval(interval);
            }
        }, 1000);
    }

    hideWarning() {
        if (this.warningModal) {
            this.warningModal.remove();
            this.warningModal = null;
        }
        this.isWarningShown = false;
    }

    continueSession() {
        console.log('✅ Usuário optou por continuar a sessão');
        this.hideWarning();
        this.onActivity(); // Registrar atividade e resetar timer
        
        // Mostrar confirmação
        if (typeof showToast !== 'undefined') {
            showToast('✅ Sessão renovada com sucesso!', 'success');
        }
    }

    async performLogout(reason = 'inatividade') {
        console.log(`🚪 Executando logout por: ${reason}`);
        
        this.hideWarning();
        
        try {
            // Verificar se há funções do sistema disponíveis
            if (typeof showToast !== 'undefined') {
                const mensagem = reason === 'inatividade' 
                    ? '⏰ Sua sessão expirou por inatividade. Faça login novamente.' 
                    : '👋 Logout realizado com sucesso!';
                showToast(mensagem, 'warning', 5000);
            }
            
            // Aguardar um pouco para a mensagem ser exibida
            await new Promise(resolve => setTimeout(resolve, 1000));
            
            // Fazer logout do Supabase
            if (window.supabase) {
                const { error } = await window.supabase.auth.signOut();
                if (error) {
                    console.error('Erro ao fazer logout:', error);
                }
            }
            
            // Limpar dados locais
            localStorage.clear();
            sessionStorage.clear();
            
            // Redirecionar para login
            window.location.href = '/index.html';
            
        } catch (error) {
            console.error('Erro ao executar logout:', error);
            // Mesmo com erro, redirecionar
            window.location.href = '/index.html';
        }
    }

    async checkSession() {
        try {
            if (!window.supabase) return;
            
            // Verificar se há sessão ativa no Supabase
            const { data: { session }, error } = await window.supabase.auth.getSession();
            
            if (error || !session) {
                console.warn('⚠️  Sessão inválida detectada, redirecionando para login...');
                await this.performLogout('sessao-invalida');
                return;
            }
            
            // Verificar se o token não está expirado
            const expiresAt = session.expires_at * 1000; // Converter para milissegundos
            const now = Date.now();
            
            if (expiresAt <= now) {
                console.warn('⚠️  Token expirado, redirecionando para login...');
                await this.performLogout('token-expirado');
                return;
            }
            
            // Verificar se o usuário ainda está ativo no banco
            const { data: userData, error: userError } = await window.supabase
                .from('users')
                .select('active')
                .eq('id', session.user.id)
                .single();
            
            if (userError || !userData || !userData.active) {
                console.warn('⚠️  Usuário não está mais ativo, redirecionando para login...');
                await this.performLogout('usuario-inativo');
                return;
            }
            
        } catch (error) {
            console.error('Erro ao verificar sessão:', error);
        }
    }

    playAlertSound() {
        try {
            // Criar um som de alerta simples usando Web Audio API
            const audioContext = new (window.AudioContext || window.webkitAudioContext)();
            const oscillator = audioContext.createOscillator();
            const gainNode = audioContext.createGain();
            
            oscillator.connect(gainNode);
            gainNode.connect(audioContext.destination);
            
            oscillator.frequency.value = 800;
            oscillator.type = 'sine';
            
            gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
            gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.5);
            
            oscillator.start(audioContext.currentTime);
            oscillator.stop(audioContext.currentTime + 0.5);
        } catch (error) {
            // Ignorar erros de áudio
            console.log('Áudio não disponível');
        }
    }

    destroy() {
        // Limpar temporizadores
        if (this.inactivityTimer) {
            clearTimeout(this.inactivityTimer);
        }
        if (this.warningTimer) {
            clearTimeout(this.warningTimer);
        }
        
        // Remover event listeners
        this.activityEvents.forEach(event => {
            document.removeEventListener(event, this.onActivity);
        });
        
        // Remover modal
        this.hideWarning();
        
        console.log('🔓 Session Manager destruído');
    }
}

// Instância global do gerenciador de sessão
let sessionManager = null;

// Inicializar automaticamente quando o DOM estiver pronto
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initSessionManager);
} else {
    initSessionManager();
}

function initSessionManager() {
    // Não inicializar na página de login
    if (window.location.pathname.includes('index.html') || window.location.pathname === '/') {
        console.log('📋 Página de login - Session Manager não iniciado');
        return;
    }
    
    // Inicializar apenas uma vez
    if (!sessionManager) {
        sessionManager = new SessionManager({
            inactivityTimeout: 15 * 60 * 1000, // 15 minutos
            warningTime: 2 * 60 * 1000 // 2 minutos de aviso
        });
    }
}

// Exportar para uso global
window.SessionManager = SessionManager;
window.sessionManager = sessionManager;
