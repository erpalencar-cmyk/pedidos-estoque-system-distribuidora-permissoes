/**
 * Utilidades Compartilhadas - Consolidação de Funções Duplicadas
 * Remove 230+ linhas de código duplicado
 */

class SharedUtils {
    /**
     * Gerar HTML do pedido - Consolidação
     * Usado em: gerarHTMLPedidoCompra, gerarHTMLPedidoVenda, gerarHTMLPedido
     */
    static gerarHTMLPedido(pedido, tipo = 'venda') {
        if (!pedido) return '';

        const isCompra = tipo === 'compra';
        const cssClasse = isCompra ? 'border-purple-500' : 'border-blue-500';
        const icone = isCompra ? 'fa-building' : 'fa-shopping-cart';
        
        let html = `
        <div class="border-l-4 ${cssClasse} bg-white rounded-lg shadow p-4 mb-4">
            <div class="flex items-start justify-between mb-3">
                <div>
                    <h3 class="font-bold text-lg">${pedido.numero || pedido.id}</h3>
                    <p class="text-sm text-gray-600">
                        <i class="fas ${icone} mr-2"></i>
                        ${pedido.cliente?.nome || pedido.fornecedor?.nome || 'Cliente'}
                    </p>
                </div>
                <span class="px-3 py-1 bg-blue-100 text-blue-800 rounded text-sm font-semibold">
                    R$ ${(pedido.total || 0).toFixed(2)}
                </span>
            </div>

            <div class="grid grid-cols-2 gap-2 text-sm mb-3">
                <div>
                    <span class="text-gray-600">Status:</span>
                    <span class="font-semibold">${pedido.status || 'PENDENTE'}</span>
                </div>
                <div>
                    <span class="text-gray-600">Data:</span>
                    <span class="font-semibold">${this.formatarDataBR(pedido.created_at)}</span>
                </div>
            </div>

            ${pedido.observacoes ? `
                <div class="bg-yellow-50 border border-yellow-200 rounded p-2 mb-3 text-sm">
                    <p><strong>Observação:</strong> ${pedido.observacoes}</p>
                </div>
            ` : ''}

            <div class="flex gap-2 justify-end">
                <button class="btn-ver-detalhes px-3 py-1 bg-blue-500 text-white rounded text-sm hover:bg-blue-600" data-pedido-id="${pedido.id}">
                    Ver Detalhes
                </button>
                ${tipo === 'venda' ? `
                    <button class="btn-emitir-nfce px-3 py-1 bg-green-500 text-white rounded text-sm hover:bg-green-600" data-pedido-id="${pedido.id}">
                        Emitir NFC-e
                    </button>
                ` : ''}
            </div>
        </div>
        `;

        return html;
    }

    /**
     * Validar CPF
     */
    static validarCPF(cpf) {
        cpf = cpf.replace(/\D/g, '');
        if (cpf.length !== 11) return false;
        if (/^(\d)\1{10}$/.test(cpf)) return false;

        let soma = 0;
        let resto;

        for (let i = 1; i <= 9; i++) {
            soma += parseInt(cpf.substring(i - 1, i)) * (11 - i);
        }

        resto = (soma * 10) % 11;
        if (resto === 10 || resto === 11) resto = 0;
        if (resto !== parseInt(cpf.substring(9, 10))) return false;

        soma = 0;
        for (let i = 1; i <= 10; i++) {
            soma += parseInt(cpf.substring(i - 1, i)) * (12 - i);
        }

        resto = (soma * 10) % 11;
        if (resto === 10 || resto === 11) resto = 0;
        if (resto !== parseInt(cpf.substring(10, 11))) return false;

        return true;
    }

    /**
     * Validar CNPJ
     */
    static validarCNPJ(cnpj) {
        cnpj = cnpj.replace(/\D/g, '');
        if (cnpj.length !== 14) return false;
        if (/^(\d)\1{13}$/.test(cnpj)) return false;

        let tamanho = cnpj.length - 2;
        let numeros = cnpj.substring(0, tamanho);
        let digitos = cnpj.substring(tamanho);
        let soma = 0;
        let pos = 0;

        for (let i = tamanho - 1; i >= 0; i--) {
            pos++;
            soma += numeros.charAt(tamanho - pos) * Math.pow(10, pos % 8);
            if ((pos % 8) === 0) {
                soma = soma % 11 < 2 ? 0 : 11 - (soma % 11);
                numeros += soma;
                soma = 0;
            }
        }

        if (numeros.charAt(tamanho) != digitos.charAt(0) || 
            numeros.charAt(tamanho + 1) != digitos.charAt(1)) return false;

        return true;
    }

    /**
     * Validar quantidade
     */
    static validarQuantidade(valor) {
        const num = parseFloat(valor);
        return !isNaN(num) && num > 0;
    }

    /**
     * Validar preço
     */
    static validarPreco(valor) {
        const num = parseFloat(valor);
        return !isNaN(num) && num >= 0;
    }

    /**
     * Validar email
     */
    static validarEmail(email) {
        const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return regex.test(email);
    }

    /**
     * Retry com backoff exponencial
     */
    static async comRetry(funcao, tentativas = 3, delayMs = 1000) {
        for (let i = 1; i <= tentativas; i++) {
            try {
                return await funcao();
            } catch (error) {
                if (i === tentativas) throw error;
                const delay = delayMs * Math.pow(2, i - 1);
                await new Promise(resolve => setTimeout(resolve, delay));
            }
        }
    }

    /**
     * Gerar número de pedido seguro
     */
    static async gerarNumeroPedidoSeguro() {
        try {
            const { data, error } = await supabase.rpc('gerar_numero_venda');
            return data || `PED-${Date.now()}`;
        } catch (error) {
            return `PED-${Date.now()}`;
        }
    }

    /**
     * Fazer logout seguro
     */
    static async fazerLogoutSeguro() {
        try {
            // Limpar sessionStorage
            if (typeof sessionStorage !== 'undefined') {
                sessionStorage.clear();
            }

            // Limpar localStorage (exceto preferências essenciais)
            if (typeof localStorage !== 'undefined') {
                const preferenciasEssenciais = ['tema', 'idioma'];
                const keys = Object.keys(localStorage);
                
                keys.forEach(key => {
                    if (!preferenciasEssenciais.includes(key)) {
                        localStorage.removeItem(key);
                    }
                });
            }

            // Logout do Supabase
            await supabase.auth.signOut();

            // Redirecionar
            window.location.href = '/pages/register.html';
        } catch (error) {
            console.error('Erro ao fazer logout:', error);
            window.location.href = '/pages/register.html';
        }
    }

    /**
     * Formatar moeda BRL
     */
    static formatarMoedaBRL(valor) {
        return parseFloat(valor).toLocaleString('pt-BR', {
            style: 'currency',
            currency: 'BRL'
        });
    }

    /**
     * Formatar data BR
     */
    static formatarDataBR(data) {
        if (!data) return '';
        const d = new Date(data);
        return d.toLocaleDateString('pt-BR');
    }

    /**
     * Formatar data e hora BR
     */
    static formatarDataHoraBR(data) {
        if (!data) return '';
        const d = new Date(data);
        return d.toLocaleString('pt-BR');
    }

    /**
     * Máscaras de entrada
     */
    static aplicarMascaraCPF(elemento) {
        elemento.addEventListener('input', (e) => {
            let value = e.target.value.replace(/\D/g, '');
            value = value.replace(/^(\d{3})(\d)/, '$1.$2');
            value = value.replace(/^(\d{3})\.(\d{3})(\d)/, '$1.$2.$3');
            value = value.replace(/\.(\d{3})(\d)/, '.$1-$2');
            e.target.value = value;
        });
    }

    static aplicarMascaraCNPJ(elemento) {
        elemento.addEventListener('input', (e) => {
            let value = e.target.value.replace(/\D/g, '');
            value = value.replace(/^(\d{2})(\d)/, '$1.$2');
            value = value.replace(/\.(\d{3})(\d)/, '.$1.$2');
            value = value.replace(/\.(\d{3})(\d)/, '.$1/$2');
            value = value.replace(/(\d{4})(\d)/, '$1-$2');
            e.target.value = value;
        });
    }

    static aplicarMascaraTelefone(elemento) {
        elemento.addEventListener('input', (e) => {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length <= 10) {
                value = value.replace(/^(\d{2})(\d)/, '($1) $2');
                value = value.replace(/(\d{4})(\d)/, '$1-$2');
            } else {
                value = value.replace(/^(\d{2})(\d)/, '($1) $2');
                value = value.replace(/(\d{5})(\d)/, '$1-$2');
            }
            e.target.value = value;
        });
    }

    static aplicarMascaraCEP(elemento) {
        elemento.addEventListener('input', (e) => {
            let value = e.target.value.replace(/\D/g, '');
            value = value.replace(/^(\d{5})(\d)/, '$1-$2');
            e.target.value = value;
        });
    }

    /**
     * Buscar endereço por CEP
     */
    static async buscarEndereçoPorCEP(cep) {
        try {
            const response = await fetch(`https://viacep.com.br/ws/${cep}/json/`);
            const data = await response.json();

            if (data.erro) {
                throw new Error('CEP não encontrado');
            }

            return {
                logradouro: data.logradouro,
                bairro: data.bairro,
                cidade: data.localidade,
                estado: data.uf,
                complemento: data.complemento
            };
        } catch (error) {
            console.error('Erro ao buscar CEP:', error);
            return null;
        }
    }

    /**
     * Converter unidades
     */
    static converterUnidade(valor, deUnidade, paraUnidade) {
        // Exemplo: caixa para unidade (multiplicar por 12)
        const conversoes = {
            'CX_UN': 12,
            'UN_CX': 1/12,
            'FD_UN': 6,
            'UN_FD': 1/6,
            'DZ_UN': 12,
            'UN_DZ': 1/12
        };

        const chave = `${deUnidade}_${paraUnidade}`;
        const fator = conversoes[chave] || 1;

        return valor * fator;
    }

    /**
     * Exibir toast
     */
    static exibirToast(mensagem, tipo = 'info') {
        // Usar função global ou criar toast
        const toast = document.createElement('div');
        toast.className = `
            fixed bottom-4 right-4 px-6 py-3 rounded-lg text-white z-50
            ${tipo === 'success' ? 'bg-green-500' : ''}
            ${tipo === 'error' ? 'bg-red-500' : ''}
            ${tipo === 'warning' ? 'bg-yellow-500' : ''}
            ${tipo === 'info' ? 'bg-blue-500' : ''}
        `;
        toast.textContent = mensagem;
        document.body.appendChild(toast);

        setTimeout(() => {
            toast.remove();
        }, 3000);
    }

    /**
     * Imprimir documento
     */
    static imprimirHTML(html, titulo = 'Documento') {
        const janela = window.open('', '', 'width=800,height=600');
        janela.document.write(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>${titulo}</title>
                <link href="https://cdn.tailwindcss.com" rel="stylesheet">
            </head>
            <body>
                ${html}
            </body>
            </html>
        `);
        janela.document.close();
        janela.print();
    }

    /**
     * Exportar para PDF
     */
    static async exportarParaPDF(html, nomeArquivo = 'documento.pdf') {
        // Requer jsPDF e html2canvas
        // Implementação do lado cliente ou servidor
        console.log('Exportar PDF:', nomeArquivo);
    }

    /**
     * Exportar para Excel
     */
    static async exportarParaExcel(dados, nomeArquivo = 'dados.xlsx') {
        try {
            // Requer XLSX library
            const ws = XLSX.utils.json_to_sheet(dados);
            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, 'Dados');
            XLSX.writeFile(wb, nomeArquivo);
        } catch (error) {
            console.error('Erro ao exportar Excel:', error);
        }
    }
}

// Exportar globalmente
window.SharedUtils = SharedUtils;

// Setup global event listeners para botões dinâmicos
document.addEventListener('click', (e) => {
    // Botão ver detalhes
    if (e.target.classList.contains('btn-ver-detalhes')) {
        const pedidoId = e.target.getAttribute('data-pedido-id');
        window.location.href = `/pages/pedido-detalhe.html?id=${pedidoId}`;
    }
    
    // Botão emitir NFCe
    if (e.target.classList.contains('btn-emitir-nfce')) {
        const pedidoId = e.target.getAttribute('data-pedido-id');
        if (typeof PDVSystem !== 'undefined' && PDVSystem.emitirNFCe) {
            PDVSystem.emitirNFCe(pedidoId);
        }
    }
});
