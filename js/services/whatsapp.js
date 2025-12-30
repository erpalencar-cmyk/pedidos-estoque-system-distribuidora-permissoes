// =====================================================
// SERVIÇO: ENVIO DE WHATSAPP
// =====================================================

/**
 * Enviar PDF de venda via WhatsApp
 */
async function enviarPDFWhatsApp(vendaId, numeroDestino) {
    try {
        showLoading(true);

        // Buscar configurações da empresa
        const empresaConfig = await getEmpresaConfig();
        
        if (!empresaConfig.whatsapp_api_provider || !empresaConfig.whatsapp_api_url) {
            throw new Error('API do WhatsApp não configurada. Configure em Configurações da Empresa.');
        }

        // Buscar dados da venda
        const { data: venda, error: vendaError } = await supabase
            .from('pedidos')
            .select(`
                *,
                solicitante:users!pedidos_solicitante_id_fkey(full_name),
                cliente:clientes(nome, whatsapp)
            `)
            .eq('id', vendaId)
            .single();

        if (vendaError) throw vendaError;

        // Gerar PDF
        const pdfBlob = await gerarPDFVenda(vendaId);
        
        // Enviar conforme o provedor configurado
        switch(empresaConfig.whatsapp_api_provider) {
            case 'evolution':
                await enviarViaEvolutionAPI(empresaConfig, numeroDestino, pdfBlob, venda);
                break;
            case 'twilio':
                await enviarViaTwilio(empresaConfig, numeroDestino, pdfBlob, venda);
                break;
            default:
                throw new Error(`Provedor ${empresaConfig.whatsapp_api_provider} não suportado`);
        }

        showToast('PDF enviado via WhatsApp com sucesso!', 'success');

    } catch (error) {
        handleError(error, 'Erro ao enviar PDF via WhatsApp');
        throw error;
    } finally {
        showLoading(false);
    }
}

/**
 * Gerar PDF da venda para envio
 */
async function gerarPDFVenda(vendaId) {
    // Buscar dados completos da venda
    const { data: venda, error: vendaError } = await supabase
        .from('pedidos')
        .select(`
            *,
            solicitante:users!pedidos_solicitante_id_fkey(full_name),
            aprovador:users!pedidos_aprovador_id_fkey(full_name),
            cliente:clientes(nome, cpf_cnpj, tipo, contato, whatsapp, endereco, cidade, estado)
        `)
        .eq('id', vendaId)
        .single();

    if (vendaError) throw vendaError;

    // Buscar itens
    const { data: itens, error: itensError } = await supabase
        .from('pedido_itens')
        .select('*, produto:produtos(codigo, nome, unidade)')
        .eq('pedido_id', vendaId)
        .order('created_at', { ascending: true });

    if (itensError) throw itensError;

    // Buscar config da empresa
    const empresaConfig = await getEmpresaConfig();

    // Gerar HTML
    const html = gerarHTMLPedidoVenda(venda, itens, empresaConfig);
    
    // Converter HTML para PDF usando biblioteca
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();
    
    // Adicionar conteúdo ao PDF
    const lines = html.split('\n');
    let y = 10;
    
    // Aqui você pode melhorar a geração do PDF
    // Por enquanto, vamos usar html2canvas ou similar
    
    return doc.output('blob');
}

/**
 * Enviar via Evolution API
 * Documentação: https://doc.evolution-api.com/
 */
async function enviarViaEvolutionAPI(config, numeroDestino, pdfBlob, venda) {
    // Preparar número (remover caracteres especiais)
    const numero = numeroDestino.replace(/\D/g, '');
    
    // Converter PDF para base64
    const base64 = await blobToBase64(pdfBlob);
    
    // Montar URL da API
    const url = `${config.whatsapp_api_url}/message/sendMedia/${config.whatsapp_instance_id}`;
    
    // Mensagem
    const mensagem = `Olá! Segue o pedido de venda #${venda.numero}.\n\nTotal: ${formatCurrency(venda.total_geral)}\n\nObrigado pela preferência!`;
    
    // Fazer requisição
    const response = await fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'apikey': config.whatsapp_api_key
        },
        body: JSON.stringify({
            number: numero,
            mediatype: 'document',
            mimetype: 'application/pdf',
            caption: mensagem,
            fileName: `venda_${venda.numero}.pdf`,
            media: base64
        })
    });

    if (!response.ok) {
        const error = await response.text();
        throw new Error(`Erro na API: ${error}`);
    }

    return await response.json();
}

/**
 * Enviar via Twilio
 * Documentação: https://www.twilio.com/docs/whatsapp
 */
async function enviarViaTwilio(config, numeroDestino, pdfBlob, venda) {
    // Primeiro fazer upload do arquivo
    const formData = new FormData();
    formData.append('file', pdfBlob, `venda_${venda.numero}.pdf`);
    
    // Upload para algum serviço público (você precisará implementar)
    // Por exemplo, upload para Supabase Storage
    const { data: upload, error: uploadError } = await supabase.storage
        .from('temp-pdfs')
        .upload(`venda_${venda.numero}_${Date.now()}.pdf`, pdfBlob, {
            cacheControl: '3600',
            upsert: false
        });
    
    if (uploadError) throw uploadError;
    
    // Obter URL pública
    const { data: { publicUrl } } = supabase.storage
        .from('temp-pdfs')
        .getPublicUrl(upload.path);
    
    // Enviar via Twilio
    const url = `https://api.twilio.com/2010-04-01/Accounts/${config.whatsapp_api_key}/Messages.json`;
    
    const response = await fetch(url, {
        method: 'POST',
        headers: {
            'Authorization': 'Basic ' + btoa(config.whatsapp_api_key + ':' + config.whatsapp_api_secret),
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: new URLSearchParams({
            From: `whatsapp:+${config.whatsapp_numero_origem}`,
            To: `whatsapp:+${numeroDestino}`,
            Body: `Olá! Segue o pedido de venda #${venda.numero}.`,
            MediaUrl: publicUrl
        })
    });

    if (!response.ok) {
        throw new Error('Erro ao enviar via Twilio');
    }

    return await response.json();
}

/**
 * Converter Blob para Base64
 */
function blobToBase64(blob) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onloadend = () => {
            const base64 = reader.result.split(',')[1];
            resolve(base64);
        };
        reader.onerror = reject;
        reader.readAsDataURL(blob);
    });
}

/**
 * Abrir WhatsApp Web com mensagem (fallback se API não configurada)
 */
function abrirWhatsAppWeb(numeroDestino, venda) {
    const numero = numeroDestino.replace(/\D/g, '');
    const mensagem = encodeURIComponent(
        `Olá! Segue o pedido de venda #${venda.numero}.\n\nTotal: ${formatCurrency(venda.total_geral)}\n\nObrigado pela preferência!`
    );
    
    const url = `https://wa.me/${numero}?text=${mensagem}`;
    window.open(url, '_blank');
}
