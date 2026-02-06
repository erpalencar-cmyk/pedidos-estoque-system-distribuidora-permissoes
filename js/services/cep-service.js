/**
 * Serviço de Consulta de CEP
 * Integra com Nuvem Fiscal para buscar endereços
 */

class CEPService {
    /**
     * Consultar CEP usando o provedor configurado
     * @param {string} cep - CEP a consultar (com ou sem máscara)
     * @returns {Object} Dados do endereço
     */
    static async consultar(cep) {
        try {
            // Remover máscara
            const cepLimpo = cep.replace(/\D/g, '');

            if (cepLimpo.length !== 8) {
                throw new Error('CEP inválido. Deve conter 8 dígitos.');
            }

            // Verificar qual provedor está configurado
            const provedor = await this.obterProvedorConfigurado();

            let resultado;

            if (provedor === 'nuvem_fiscal') {
                // Usar Nuvem Fiscal
                resultado = await NuvemFiscal.consultarCEP(cepLimpo);
            } else {
                // Fallback: usar API pública ViaCEP como alternativa
                resultado = await this.consultarViaCEP(cepLimpo);
            }

            return resultado;
        } catch (erro) {
            console.error('Erro ao consultar CEP:', erro);
            throw erro;
        }
    }

    /**
     * Obter provedor de API fiscal configurado
     */
    static async obterProvedorConfigurado() {
        try {
            const { data: session } = await supabase.auth.getSession();
            if (!session?.session?.user) {
                return 'viacep'; // Fallback para API pública se não autenticado
            }

            const { data: config } = await supabase
                .from('empresa_config')
                .select('api_fiscal_provider')
                .eq('empresa_id', session.session.user.id)
                .single();

            return config?.api_fiscal_provider || 'viacep';
        } catch (erro) {
            console.warn('Erro ao obter provedor:', erro);
            return 'viacep'; // Fallback
        }
    }

    /**
     * Consultar CEP via ViaCEP (API pública gratuita)
     * Usado como fallback ou quando Nuvem Fiscal não está configurada
     */
    static async consultarViaCEP(cep) {
        try {
            const response = await fetch(`https://viacep.com.br/ws/${cep}/json/`);
            
            if (!response.ok) {
                throw new Error('Erro ao consultar CEP');
            }

            const data = await response.json();

            if (data.erro) {
                throw new Error('CEP não encontrado');
            }

            // Padronizar formato de resposta
            return {
                cep: data.cep,
                logradouro: data.logradouro || '',
                complemento: data.complemento || '',
                bairro: data.bairro || '',
                cidade: data.localidade || '',
                uf: data.uf || '',
                codigo_ibge: data.ibge || '',
                tipo_logradouro: ''
            };
        } catch (erro) {
            console.error('Erro ao consultar ViaCEP:', erro);
            throw erro;
        }
    }

    /**
     * Preencher campos de endereço automaticamente
     * @param {string} cep - CEP consultado
     * @param {string} prefixo - Prefixo dos IDs dos campos (ex: 'cliente-', 'empresa-')
     */
    static async preencherEndereco(cep, prefixo = '') {
        try {
            // Mostrar loading
            this.mostrarLoading(prefixo);

            // Consultar CEP
            const endereco = await this.consultar(cep);

            // Preencher campos
            const camposMap = {
                logradouro: `${prefixo}logradouro`,
                complemento: `${prefixo}complemento`,
                bairro: `${prefixo}bairro`,
                cidade: `${prefixo}cidade`,
                uf: `${prefixo}uf`,
                codigo_ibge: `${prefixo}codigo_ibge`
            };

            Object.keys(camposMap).forEach(campo => {
                const elemento = document.getElementById(camposMap[campo]);
                if (elemento && endereco[campo]) {
                    elemento.value = endereco[campo];
                    
                    // Disparar evento change para atualizar listeners
                    elemento.dispatchEvent(new Event('change', { bubbles: true }));
                }
            });

            // Focar no campo número (geralmente precisa ser preenchido manualmente)
            const campoNumero = document.getElementById(`${prefixo}numero`);
            if (campoNumero) {
                campoNumero.focus();
            }

            this.esconderLoading(prefixo);

            return endereco;
        } catch (erro) {
            this.esconderLoading(prefixo);
            
            // Mostrar erro ao usuário
            this.mostrarErro('CEP não encontrado ou inválido', prefixo);
            throw erro;
        }
    }

    /**
     * Adicionar botão de consulta CEP a um campo
     * @param {string} idCampoCEP - ID do campo input de CEP
     * @param {string} prefixo - Prefixo dos campos de endereço
     */
    static adicionarBotaoConsulta(idCampoCEP, prefixo = '') {
        const campoCEP = document.getElementById(idCampoCEP);
        if (!campoCEP) {
            console.warn(`Campo ${idCampoCEP} não encontrado`);
            return;
        }

        // Criar container para o botão
        const container = campoCEP.parentElement;
        container.style.position = 'relative';

        // Criar botão
        const botao = document.createElement('button');
        botao.type = 'button';
        botao.className = 'btn-consultar-cep absolute right-2 top-1/2 transform -translate-y-1/2 text-teal-600 hover:text-teal-700 px-3 py-1 rounded';
        botao.innerHTML = '<i class="fas fa-search"></i>';
        botao.title = 'Buscar endereço';
        botao.style.cssText = 'position: absolute; right: 0.5rem; top: 50%; transform: translateY(-50%); z-index: 10;';

        // Adicionar evento de clique
        botao.onclick = async () => {
            const cep = campoCEP.value;
            if (cep && cep.replace(/\D/g, '').length === 8) {
                await this.preencherEndereco(cep, prefixo);
            } else {
                alert('Por favor, digite um CEP válido com 8 dígitos');
            }
        };

        container.appendChild(botao);

        // Adicionar evento ao pressionar Enter no campo CEP
        campoCEP.addEventListener('keypress', async (e) => {
            if (e.key === 'Enter') {
                e.preventDefault();
                botao.click();
            }
        });

        // Auto-consultar ao sair do campo (blur) se CEP estiver completo
        campoCEP.addEventListener('blur', async () => {
            const cep = campoCEP.value;
            if (cep && cep.replace(/\D/g, '').length === 8) {
                const logradouro = document.getElementById(`${prefixo}logradouro`);
                // Só consultar se o logradouro estiver vazio
                if (logradouro && !logradouro.value) {
                    await this.preencherEndereco(cep, prefixo);
                }
            }
        });
    }

    /**
     * Mostrar indicador de loading
     */
    static mostrarLoading(prefixo) {
        const campos = ['logradouro', 'bairro', 'cidade', 'uf'];
        campos.forEach(campo => {
            const elemento = document.getElementById(`${prefixo}${campo}`);
            if (elemento) {
                elemento.style.opacity = '0.5';
                elemento.disabled = true;
            }
        });
    }

    /**
     * Esconder indicador de loading
     */
    static esconderLoading(prefixo) {
        const campos = ['logradouro', 'bairro', 'cidade', 'uf'];
        campos.forEach(campo => {
            const elemento = document.getElementById(`${prefixo}${campo}`);
            if (elemento) {
                elemento.style.opacity = '1';
                elemento.disabled = false;
            }
        });
    }

    /**
     * Mostrar mensagem de erro
     */
    static mostrarErro(mensagem, prefixo) {
        const campoCEP = document.getElementById(`${prefixo}cep`);
        if (campoCEP) {
            // Adicionar classe de erro
            campoCEP.classList.add('border-red-500');
            
            // Remover classe após 3 segundos
            setTimeout(() => {
                campoCEP.classList.remove('border-red-500');
            }, 3000);
        }

        // Mostrar toast ou alert
        if (typeof mostrarToast === 'function') {
            mostrarToast(mensagem, 'erro');
        } else {
            console.error(mensagem);
        }
    }

    /**
     * Formatar CEP com máscara
     * @param {string} cep - CEP sem máscara
     * @returns {string} CEP formatado (00000-000)
     */
    static formatarCEP(cep) {
        const cepLimpo = cep.replace(/\D/g, '');
        if (cepLimpo.length === 8) {
            return `${cepLimpo.substr(0, 5)}-${cepLimpo.substr(5, 3)}`;
        }
        return cep;
    }

    /**
     * Aplicar máscara de CEP em campo input
     * @param {HTMLInputElement} campo - Campo input
     */
    static aplicarMascara(campo) {
        if (!campo) return;

        campo.addEventListener('input', (e) => {
            let valor = e.target.value.replace(/\D/g, '');
            
            if (valor.length > 8) {
                valor = valor.substr(0, 8);
            }

            if (valor.length > 5) {
                valor = `${valor.substr(0, 5)}-${valor.substr(5)}`;
            }

            e.target.value = valor;
        });
    }
}

// Inicializar automaticamente ao carregar a página
document.addEventListener('DOMContentLoaded', () => {
    // Buscar todos os campos de CEP e adicionar botões
    const camposCEP = document.querySelectorAll('input[id*="cep"], input[name*="cep"]');
    
    camposCEP.forEach(campo => {
        // Aplicar máscara
        CEPService.aplicarMascara(campo);
        
        // Tentar detectar prefixo do campo
        const prefixo = campo.id.replace('cep', '');
        
        // Adicionar botão de consulta
        CEPService.adicionarBotaoConsulta(campo.id, prefixo);
    });
});
