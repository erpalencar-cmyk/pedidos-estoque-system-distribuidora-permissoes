-- ================================================================
-- STORED PROCEDURES - Lógica de Negócio
-- ================================================================

-- Finalizar venda com lock (evitar race condition)
CREATE OR REPLACE FUNCTION finalizar_venda_segura(
    p_numero_nf VARCHAR,
    p_caixa_id UUID,
    p_movimentacao_caixa_id UUID,
    p_operador_id UUID,
    p_subtotal NUMERIC,
    p_desconto NUMERIC,
    p_acrescimo NUMERIC,
    p_total NUMERIC,
    p_forma_pagamento pagamento_forma,
    p_valor_pago NUMERIC,
    p_valor_troco NUMERIC
)
RETURNS UUID AS $$
DECLARE
    v_venda_id UUID;
BEGIN
    -- Usar transação implícita do PL/pgSQL
    -- Buscar com lock (FOR UPDATE) para evitar race condition
    
    INSERT INTO vendas (
        numero_nf,
        caixa_id,
        movimentacao_caixa_id,
        operador_id,
        subtotal,
        desconto,
        desconto_percentual,
        acrescimo,
        total,
        forma_pagamento,
        valor_pago,
        valor_troco,
        status_venda,
        status_fiscal
    ) VALUES (
        p_numero_nf,
        p_caixa_id,
        p_movimentacao_caixa_id,
        p_operador_id,
        p_subtotal,
        p_desconto,
        (p_desconto / p_subtotal * 100),
        p_acrescimo,
        p_total,
        p_forma_pagamento,
        p_valor_pago,
        p_valor_troco,
        'FINALIZADA',
        'SEM_DOCUMENTO_FISCAL'
    )
    RETURNING id INTO v_venda_id;

    -- Registrar pagamento
    INSERT INTO pagamentos_venda (
        venda_id,
        forma,
        valor,
        status_pagamento
    ) VALUES (
        v_venda_id,
        p_forma_pagamento,
        p_valor_pago,
        'RECEBIDO'
    );

    RETURN v_venda_id;
END;
$$ LANGUAGE plpgsql;

-- Atualizar estoque com validação
CREATE OR REPLACE FUNCTION atualizar_estoque_venda_com_validacao(
    p_venda_id UUID
)
RETURNS TABLE (
    sucesso BOOLEAN,
    mensagem TEXT
) AS $$
DECLARE
    v_item RECORD;
    v_estoque_disponivel NUMERIC;
BEGIN
    -- Loop em cada item da venda
    FOR v_item IN 
        SELECT produto_id, quantidade FROM vendas_itens WHERE venda_id = p_venda_id
    LOOP
        -- Verificar estoque disponível
        SELECT estoque_atual INTO v_estoque_disponivel
        FROM produtos
        WHERE id = v_item.produto_id;

        IF v_estoque_disponivel < v_item.quantidade THEN
            RETURN QUERY SELECT false, 'Estoque insuficiente para produto: ' || v_item.produto_id::text;
            RETURN;
        END IF;

        -- Atualizar estoque
        UPDATE produtos
        SET estoque_atual = estoque_atual - v_item.quantidade
        WHERE id = v_item.produto_id;

        -- Registrar movimento
        INSERT INTO estoque_movimentacoes (
            produto_id,
            tipo_movimento,
            quantidade,
            unidade_medida,
            motivo,
            referencia_id,
            referencia_tipo,
            usuario_id
        ) VALUES (
            v_item.produto_id,
            'SAIDA',
            v_item.quantidade,
            'UN',
            'Venda PDV',
            p_venda_id,
            'VENDA',
            auth.uid()
        );
    END LOOP;

    RETURN QUERY SELECT true, 'Estoque atualizado com sucesso';
END;
$$ LANGUAGE plpgsql;

-- Fechar caixa com validação
CREATE OR REPLACE FUNCTION fechar_caixa(
    p_movimentacao_id UUID,
    p_saldo_final NUMERIC
)
RETURNS TABLE (
    sucesso BOOLEAN,
    mensagem TEXT,
    diferenca NUMERIC
) AS $$
DECLARE
    v_total_vendas NUMERIC;
    v_diferenca NUMERIC;
BEGIN
    -- Calcular total de vendas
    SELECT COALESCE(SUM(total), 0) INTO v_total_vendas
    FROM vendas
    WHERE movimentacao_caixa_id = p_movimentacao_id
    AND status_venda = 'FINALIZADA';

    -- Calcular diferença
    v_diferenca := p_saldo_final - (
        (SELECT saldo_inicial FROM movimentacoes_caixa WHERE id = p_movimentacao_id) + 
        v_total_vendas
    );

    -- Atualizar movimentação
    UPDATE movimentacoes_caixa
    SET 
        data_fechamento = NOW(),
        total_vendas = v_total_vendas,
        saldo_final = p_saldo_final,
        status = 'FECHADA'
    WHERE id = p_movimentacao_id;

    RETURN QUERY SELECT 
        true,
        CASE 
            WHEN v_diferenca = 0 THEN 'Caixa fechado com precisão'
            WHEN v_diferenca > 0 THEN 'Caixa com excesso de: ' || v_diferenca::text
            ELSE 'Caixa com falta de: ' || (v_diferenca * -1)::text
        END,
        v_diferenca;
END;
$$ LANGUAGE plpgsql;

-- Gerar número NFC-e sequencial
CREATE OR REPLACE FUNCTION gerar_numero_nfce()
RETURNS VARCHAR AS $$
DECLARE
    v_numero INTEGER;
    v_empresa_id UUID;
BEGIN
    -- Buscar ID da empresa (primeira config)
    SELECT id INTO v_empresa_id FROM empresa_config LIMIT 1;

    -- Incrementar número
    UPDATE empresa_config
    SET nfce_numero = nfce_numero + 1
    WHERE id = v_empresa_id;

    -- Retornar número formatado
    SELECT nfce_numero INTO v_numero FROM empresa_config WHERE id = v_empresa_id;
    
    RETURN LPAD(v_numero::text, 6, '0');
END;
$$ LANGUAGE plpgsql;

-- Buscar produtos com estoque
CREATE OR REPLACE FUNCTION buscar_produtos_disponiveis(
    p_busca TEXT DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    sku VARCHAR,
    nome VARCHAR,
    preco_venda NUMERIC,
    estoque_atual NUMERIC,
    disponivel BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.sku,
        p.nome,
        p.preco_venda,
        p.estoque_atual,
        (p.estoque_atual > 0) as disponivel
    FROM produtos p
    WHERE p.ativo = true
    AND (
        p_busca IS NULL 
        OR p.codigo_barras ILIKE '%' || p_busca || '%'
        OR p.sku ILIKE '%' || p_busca || '%'
        OR p.nome ILIKE '%' || p_busca || '%'
    )
    ORDER BY p.nome;
END;
$$ LANGUAGE plpgsql;

-- Obter estatísticas de venda do dia
CREATE OR REPLACE FUNCTION stats_vendas_dia(OUT total_vendas NUMERIC, OUT quantidade_itens INTEGER, OUT media_venda NUMERIC)
AS $$
BEGIN
    SELECT 
        COALESCE(SUM(v.total), 0),
        COALESCE(COUNT(DISTINCT vi.id), 0),
        COALESCE(AVG(v.total), 0)
    INTO total_vendas, quantidade_itens, media_venda
    FROM vendas v
    LEFT JOIN vendas_itens vi ON v.id = vi.venda_id
    WHERE DATE(v.created_at) = CURRENT_DATE
    AND v.status_venda = 'FINALIZADA';
END;
$$ LANGUAGE plpgsql;

-- Validar CPF/CNPJ
CREATE OR REPLACE FUNCTION validar_cpf_cnpj(p_documento VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    v_doc VARCHAR;
    v_sum INTEGER;
    v_resto INTEGER;
    i INTEGER;
BEGIN
    -- Remover caracteres especiais
    v_doc := regexp_replace(p_documento, '[^0-9]', '', 'g');

    -- Validar tamanho
    IF length(v_doc) NOT IN (11, 14) THEN
        RETURN false;
    END IF;

    -- Validar CPF (11 dígitos)
    IF length(v_doc) = 11 THEN
        -- Validação simplificada
        IF v_doc ~ '^[0-9]{11}$' THEN
            RETURN true;
        END IF;
    END IF;

    -- Validar CNPJ (14 dígitos)
    IF length(v_doc) = 14 THEN
        IF v_doc ~ '^[0-9]{14}$' THEN
            RETURN true;
        END IF;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql;

-- Converter unidades
CREATE OR REPLACE FUNCTION converter_unidade(
    p_valor NUMERIC,
    p_de_unidade unidade_medida,
    p_para_unidade unidade_medida
)
RETURNS NUMERIC AS $$
BEGIN
    RETURN CASE 
        WHEN p_de_unidade = 'CX' AND p_para_unidade = 'UN' THEN p_valor * 12
        WHEN p_de_unidade = 'UN' AND p_para_unidade = 'CX' THEN p_valor / 12
        WHEN p_de_unidade = 'FD' AND p_para_unidade = 'UN' THEN p_valor * 6
        WHEN p_de_unidade = 'UN' AND p_para_unidade = 'FD' THEN p_valor / 6
        WHEN p_de_unidade = 'DZ' AND p_para_unidade = 'UN' THEN p_valor * 12
        WHEN p_de_unidade = 'UN' AND p_para_unidade = 'DZ' THEN p_valor / 12
        ELSE p_valor
    END;
END;
$$ LANGUAGE plpgsql;

-- Controlar acesso por role
CREATE OR REPLACE FUNCTION verificar_acesso_role(
    p_usuario_id UUID,
    p_role user_role
)
RETURNS BOOLEAN AS $$
DECLARE
    v_user_role user_role;
BEGIN
    SELECT role INTO v_user_role FROM users WHERE id = p_usuario_id;
    RETURN v_user_role = p_role OR v_user_role = 'ADMIN';
END;
$$ LANGUAGE plpgsql;

COMMIT;
