/**
 * Serviço de Consulta de CNPJ
 * Integra com Nuvem Fiscal para buscar dados cadastrais de empresas
 */

class CNPJService {
    /**
     * Consultar CNPJ usando o provedor configurado
     * @param {string} cnpj - CNPJ a consultar (com ou sem máscara)
     * @returns {Object} Dados cadastrais da empresa
     */
    static async consultar(cnpj) {
        try {
            // Remover máscara
            const cnpjLimpo = cnpj.replace(/\D/g, '');

            if (cnpjLimpo.length !== 14) {
                throw new Error('CNPJ inválido. Deve conter 14 dígitos.');
            }

            // Verificar qual provedor está configurado
            const provedor = await this.obterProvedorConfigurado();

            let resultado;

            if (provedor === 'nuvem_fiscal') {
                // Usar Nuvem Fiscal
                resultado = await NuvemFiscal.consultarCNPJ(cnpjLimpo);
            } else {
                // Informar que precisa configurar Nuvem Fiscal
                throw new Error('Configure a Nuvem Fiscal para consultar CNPJ');
            }

            return resultado;
        } catch (erro) {
            console.error('Erro ao consultar CNPJ:', erro);
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
                throw new Error('Usuário não autenticado');
            }

            const { data: config } = await supabase
                .from('empresa_config')
                .select('api_fiscal_provider')
                .eq('empresa_id', session.session.user.id)
                .single();

            return config?.api_fiscal_provider || 'focus_nfe';
        } catch (erro) {
            console.warn('Erro ao obter provedor:', erro);
            return 'focus_nfe';
        }
    }

    /**
     * Preencher dados da empresa automaticamente
     * @param {string} cnpj - CNPJ consultado
     * @param {string} prefixo - Prefixo dos IDs dos campos (ex: 'empresa-', 'fornecedor-')
     */
    static async preencherDados(cnpj, prefixo = '') {
        try {
            // Mostrar loading
            this.mostrarLoading(prefixo);

            // Consultar CNPJ
            const empresa = await this.consultar(cnpj);

            // Verificar situação cadastral
            if (empresa.situacao_cadastral !== '02' && empresa.situacao_cadastral !== 'ATIVA') {
                const confirmar = confirm(
                    `ATENÇÃO: Este CNPJ está ${empresa.situacao_cadastral}.\n\nDeseja continuar?`
                );
                if (!confirmar) {
                    this.esconderLoading(prefixo);
                    return null;
                }
            }

            // Mapa de campos
            const camposMap = {
                // Dados básicos
                razao_social: `${prefixo}razao_social`,
                nome_fantasia: `${prefixo}nome_fantasia`,
                
                // Endereço
                logradouro: `${prefixo}logradouro`,
                numero: `${prefixo}numero`,
                complemento: `${prefixo}complemento`,
                bairro: `${prefixo}bairro`,
                cep: `${prefixo}cep`,
                cidade: `${prefixo}cidade`,
                uf: `${prefixo}uf`,
                
                // Contato
                telefone: `${prefixo}telefone`,
                email: `${prefixo}email`,
                
                // Dados fiscais
                inscricao_estadual: `${prefixo}inscricao_estadual`,
                cnae_principal: `${prefixo}cnae_principal`,
                natureza_juridica: `${prefixo}natureza_juridica`,
                porte: `${prefixo}porte`,
                capital_social: `${prefixo}capital_social`,
                data_abertura: `${prefixo}data_abertura`
            };

            // Preencher campos
            Object.keys(camposMap).forEach(campo => {
                const elemento = document.getElementById(camposMap[campo]);
                if (elemento && empresa[campo]) {
                    // Formatar valores especiais
                    let valor = empresa[campo];
                    
                    if (campo === 'cep') {
                        valor = this.formatarCEP(valor);
                    } else if (campo === 'telefone') {
                        valor = this.formatarTelefone(valor);
                    } else if (campo === 'capital_social') {
                        valor = this.formatarValor(valor);
                    }
                    
                    elemento.value = valor;
                    
                    // Disparar evento change
                    elemento.dispatchEvent(new Event('change', { bubbles: true }));
                }
            });

            // Preencher checkboxes (Simples Nacional, MEI)
            const checkSimples = document.getElementById(`${prefixo}simples_nacional`);
            if (checkSimples) {
                checkSimples.checked = empresa.simples_nacional || false;
            }

            const checkMEI = document.getElementById(`${prefixo}mei`);
            if (checkMEI) {
                checkMEI.checked = empresa.mei || false;
            }

            this.esconderLoading(prefixo);

            // Mostrar resumo dos dados
            this.mostrarResumo(empresa);

            return empresa;
        } catch (erro) {
            this.esconderLoading(prefixo);
            
            // Mostrar erro ao usuário
            this.mostrarErro(erro.message || 'Erro ao consultar CNPJ', prefixo);
            throw erro;
        }
    }

    /**
     * Adicionar botão de consulta CNPJ a um campo
     * @param {string} idCampoCNPJ - ID do campo input de CNPJ
     * @param {string} prefixo - Prefixo dos campos
     */
    static adicionarBotaoConsulta(idCampoCNPJ, prefixo = '') {
        const campoCNPJ = document.getElementById(idCampoCNPJ);
        if (!campoCNPJ) {
            console.warn(`Campo ${idCampoCNPJ} não encontrado`);
            return;
        }

        // Criar container para o botão
        const container = campoCNPJ.parentElement;
        container.style.position = 'relative';

        // Criar botão
        const botao = document.createElement('button');
        botao.type = 'button';
        botao.className = 'btn-consultar-cnpj absolute right-2 top-1/2 transform -translate-y-1/2 text-teal-600 hover:text-teal-700 px-3 py-1 rounded';
        botao.innerHTML = '<i class="fas fa-search"></i>';
        botao.title = 'Buscar dados da empresa';
        botao.style.cssText = 'position: absolute; right: 0.5rem; top: 50%; transform: translateY(-50%); z-index: 10;';

        // Adicionar evento de clique
        botao.onclick = async () => {
            const cnpj = campoCNPJ.value;
            if (cnpj && cnpj.replace(/\D/g, '').length === 14) {
                try {
                    await this.preencherDados(cnpj, prefixo);
                } catch (erro) {
                    console.error('Erro ao consultar CNPJ:', erro);
                }
            } else {
                alert('Por favor, digite um CNPJ válido com 14 dígitos');
            }
        };

        container.appendChild(botao);

        // Adicionar evento ao pressionar Enter
        campoCNPJ.addEventListener('keypress', async (e) => {
            if (e.key === 'Enter') {
                e.preventDefault();
                botao.click();
            }
        });
    }

    /**
     * Mostrar indicador de loading
     */
    static mostrarLoading(prefixo) {
        const campos = [
            'razao_social', 'nome_fantasia', 'logradouro', 'numero', 
            'bairro', 'cidade', 'uf', 'cep', 'telefone', 'email'
        ];
        
        campos.forEach(campo => {
            const elemento = document.getElementById(`${prefixo}${campo}`);
            if (elemento) {
                elemento.style.opacity = '0.5';
                elemento.disabled = true;
            }
        });

        // Mostrar indicador visual
        const campoCNPJ = document.getElementById(`${prefixo}cnpj`) || document.getElementById(`${prefixo}cpf_cnpj`);
        if (campoCNPJ) {
            campoCNPJ.classList.add('border-blue-500', 'animate-pulse');
        }
    }

    /**
     * Esconder indicador de loading
     */
    static esconderLoading(prefixo) {
        const campos = [
            'razao_social', 'nome_fantasia', 'logradouro', 'numero', 
            'bairro', 'cidade', 'uf', 'cep', 'telefone', 'email'
        ];
        
        campos.forEach(campo => {
            const elemento = document.getElementById(`${prefixo}${campo}`);
            if (elemento) {
                elemento.style.opacity = '1';
                elemento.disabled = false;
            }
        });

        const campoCNPJ = document.getElementById(`${prefixo}cnpj`) || document.getElementById(`${prefixo}cpf_cnpj`);
        if (campoCNPJ) {
            campoCNPJ.classList.remove('border-blue-500', 'animate-pulse');
        }
    }

    /**
     * Mostrar mensagem de erro
     */
    static mostrarErro(mensagem, prefixo) {
        const campoCNPJ = document.getElementById(`${prefixo}cnpj`) || document.getElementById(`${prefixo}cpf_cnpj`);
        if (campoCNPJ) {
            campoCNPJ.classList.add('border-red-500');
            
            setTimeout(() => {
                campoCNPJ.classList.remove('border-red-500');
            }, 3000);
        }

        // Mostrar toast ou alert
        if (typeof mostrarToast === 'function') {
            mostrarToast(mensagem, 'erro');
        } else {
            alert(mensagem);
        }
    }

    /**
     * Mostrar resumo dos dados consultados
     */
    static mostrarResumo(empresa) {
        const resumo = `
✅ CNPJ consultado com sucesso!

📋 Dados preenchidos:
• Razão Social: ${empresa.razao_social}
• Nome Fantasia: ${empresa.nome_fantasia || 'Não informado'}
• Situação: ${empresa.situacao_cadastral}
• Endereço: ${empresa.logradouro}, ${empresa.numero} - ${empresa.bairro}
• Cidade: ${empresa.cidade}/${empresa.uf}
• Atividade: ${empresa.descricao_cnae || 'Não informado'}
        `.trim();

        if (typeof mostrarToast === 'function') {
            mostrarToast('Dados da empresa preenchidos com sucesso!', 'sucesso');
        } else {
            console.log(resumo);
        }
    }

    /**
     * Formatar CNPJ com máscara
     * @param {string} cnpj - CNPJ sem máscara
     * @returns {string} CNPJ formatado (00.000.000/0000-00)
     */
    static formatarCNPJ(cnpj) {
        const cnpjLimpo = cnpj.replace(/\D/g, '');
        if (cnpjLimpo.length === 14) {
            return cnpjLimpo.replace(
                /^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})$/,
                '$1.$2.$3/$4-$5'
            );
        }
        return cnpj;
    }

    /**
     * Formatar CEP com máscara
     */
    static formatarCEP(cep) {
        const cepLimpo = cep.replace(/\D/g, '');
        if (cepLimpo.length === 8) {
            return `${cepLimpo.substr(0, 5)}-${cepLimpo.substr(5, 3)}`;
        }
        return cep;
    }

    /**
     * Formatar telefone
     */
    static formatarTelefone(telefone) {
        const telLimpo = telefone.replace(/\D/g, '');
        if (telLimpo.length === 11) {
            return telLimpo.replace(/^(\d{2})(\d{5})(\d{4})$/, '($1) $2-$3');
        } else if (telLimpo.length === 10) {
            return telLimpo.replace(/^(\d{2})(\d{4})(\d{4})$/, '($1) $2-$3');
        }
        return telefone;
    }

    /**
     * Formatar valor monetário
     */
    static formatarValor(valor) {
        return parseFloat(valor).toFixed(2);
    }

    /**
     * Aplicar máscara de CNPJ em campo input
     * @param {HTMLInputElement} campo - Campo input
     */
    static aplicarMascara(campo) {
        if (!campo) return;

        campo.addEventListener('input', (e) => {
            let valor = e.target.value.replace(/\D/g, '');
            
            if (valor.length > 14) {
                valor = valor.substr(0, 14);
            }

            // Aplicar máscara: 00.000.000/0000-00
            if (valor.length > 2) {
                valor = valor.replace(/^(\d{2})(\d)/, '$1.$2');
            }
            if (valor.length > 6) {
                valor = valor.replace(/^(\d{2})\.(\d{3})(\d)/, '$1.$2.$3');
            }
            if (valor.length > 10) {
                valor = valor.replace(/^(\d{2})\.(\d{3})\.(\d{3})(\d)/, '$1.$2.$3/$4');
            }
            if (valor.length > 15) {
                valor = valor.replace(/^(\d{2})\.(\d{3})\.(\d{3})\/(\d{4})(\d)/, '$1.$2.$3/$4-$5');
            }

            e.target.value = valor;
        });
    }

    /**
     * Validar CNPJ
     * @param {string} cnpj - CNPJ a validar
     * @returns {boolean} True se válido
     */
    static validar(cnpj) {
        const cnpjLimpo = cnpj.replace(/\D/g, '');

        if (cnpjLimpo.length !== 14) return false;

        // Validar dígitos verificadores
        let tamanho = cnpjLimpo.length - 2;
        let numeros = cnpjLimpo.substring(0, tamanho);
        const digitos = cnpjLimpo.substring(tamanho);
        let soma = 0;
        let pos = tamanho - 7;

        for (let i = tamanho; i >= 1; i--) {
            soma += numeros.charAt(tamanho - i) * pos--;
            if (pos < 2) pos = 9;
        }

        let resultado = soma % 11 < 2 ? 0 : 11 - (soma % 11);
        if (resultado != digitos.charAt(0)) return false;

        tamanho = tamanho + 1;
        numeros = cnpjLimpo.substring(0, tamanho);
        soma = 0;
        pos = tamanho - 7;

        for (let i = tamanho; i >= 1; i--) {
            soma += numeros.charAt(tamanho - i) * pos--;
            if (pos < 2) pos = 9;
        }

        resultado = soma % 11 < 2 ? 0 : 11 - (soma % 11);
        if (resultado != digitos.charAt(1)) return false;

        return true;
    }
}

// Inicializar automaticamente ao carregar a página
document.addEventListener('DOMContentLoaded', () => {
    // Buscar todos os campos de CNPJ e adicionar botões
    const camposCNPJ = document.querySelectorAll('input[id*="cnpj"], input[name*="cnpj"]');
    
    camposCNPJ.forEach(campo => {
        // Aplicar máscara
        CNPJService.aplicarMascara(campo);
        
        // Tentar detectar prefixo do campo
        const prefixo = campo.id.replace('cnpj', '').replace('cpf_cnpj', '');
        
        // Adicionar botão de consulta
        CNPJService.adicionarBotaoConsulta(campo.id, prefixo);
    });
});
