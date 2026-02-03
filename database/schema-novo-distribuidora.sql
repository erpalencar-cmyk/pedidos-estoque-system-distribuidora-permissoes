-- ================================================================
-- SCHEMA NOVO - SISTEMA PDV DISTRIBUIDORA DE BEBIDAS
-- Totalmente reformulado para fluxo de vendas estilo supermercado
-- ================================================================

-- ======================== EXTENSÕES =============================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ======================== TIPOS CUSTOMIZADOS ====================
CREATE TYPE user_role AS ENUM (
    'ADMIN',
    'GERENTE',
    'VENDEDOR',
    'OPERADOR_CAIXA',
    'ESTOQUISTA',
    'COMPRADOR',
    'APROVADOR'
);

CREATE TYPE venda_status AS ENUM (
    'ABERTA',
    'FINALIZADA',
    'CANCELADA',
    'DEVOLVIDA'
);

CREATE TYPE documento_fiscal_status AS ENUM (
    'SEM_DOCUMENTO_FISCAL',
    'PENDENTE_EMISSAO',
    'EMITIDA_NFCE',
    'EMITIDA_NFE',
    'REJEITADA_SEFAZ',
    'CANCELADA'
);

CREATE TYPE pagamento_forma AS ENUM (
    'DINHEIRO',
    'CARTAO_CREDITO',
    'CARTAO_DEBITO',
    'PIX',
    'CHEQUE',
    'VALE',
    'PRAZO'
);

CREATE TYPE unidade_medida AS ENUM (
    'UN',      -- Unidade
    'CX',      -- Caixa
    'FD',      -- Fardo
    'DZ',      -- Dúzia
    'L',       -- Litro
    'KG',      -- Quilograma
    'PCT'      -- Pacote
);

-- ======================== TABELAS BASE ==========================

-- Empresa
CREATE TABLE IF NOT EXISTS empresa_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome_empresa VARCHAR(200) NOT NULL,
    razao_social VARCHAR(200),
    cnpj VARCHAR(18) UNIQUE,
    inscricao_estadual VARCHAR(20),
    inscricao_municipal VARCHAR(20),
    logo_url TEXT,
    endereco TEXT,
    numero VARCHAR(10),
    complemento TEXT,
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    cep VARCHAR(10),
    telefone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(200),
    
    -- Fiscal
    regime_tributario VARCHAR(1), -- 1, 2, 3
    cnae VARCHAR(10),
    codigo_municipio VARCHAR(7),
    logradouro VARCHAR(255),
    
    -- Focus NFe
    nfe_ambiente VARCHAR(1) DEFAULT '2', -- 1 produção, 2 homologação
    nfe_token TEXT,
    nfce_serie INTEGER DEFAULT 1,
    nfe_serie INTEGER DEFAULT 1,
    nfce_numero INTEGER DEFAULT 1,
    nfe_numero INTEGER DEFAULT 1,
    
    -- PDV
    pdv_emitir_nfce BOOLEAN DEFAULT false,
    pdv_imprimir_cupom BOOLEAN DEFAULT true,
    pdv_permitir_venda_zerado BOOLEAN DEFAULT false,
    pdv_desconto_maximo BOOLEAN DEFAULT false,
    pdv_desconto_limite NUMERIC(5,2) DEFAULT 10.00,
    pdv_mensagem_cupom TEXT,
    
    -- WhatsApp
    whatsapp_api_provider VARCHAR(50),
    whatsapp_numero_origem VARCHAR(20),
    whatsapp_api_url TEXT,
    whatsapp_api_key TEXT,
    whatsapp_instance_id VARCHAR(100),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Usuários
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    nome_completo VARCHAR(255) NOT NULL,
    cpf VARCHAR(14) UNIQUE,
    role user_role NOT NULL DEFAULT 'VENDEDOR',
    telefone VARCHAR(20),
    whatsapp VARCHAR(20),
    ativo BOOLEAN DEFAULT true,
    email_confirmado BOOLEAN DEFAULT false,
    ultimo_login TIMESTAMP WITH TIME ZONE,
    senha_hash VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Clientes
CREATE TABLE IF NOT EXISTS clientes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(255) NOT NULL,
    tipo VARCHAR(10), -- 'PJ' ou 'PF'
    cpf_cnpj VARCHAR(18) UNIQUE,
    inscricao_estadual VARCHAR(20),
    endereco TEXT,
    numero VARCHAR(10),
    complemento TEXT,
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    cep VARCHAR(10),
    telefone VARCHAR(20),
    whatsapp VARCHAR(20),
    email VARCHAR(100),
    limite_credito NUMERIC(12,2) DEFAULT 0.00,
    saldo_devedor NUMERIC(12,2) DEFAULT 0.00,
    tabela_preco_custom BOOLEAN DEFAULT false,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Fornecedores
CREATE TABLE IF NOT EXISTS fornecedores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(255) NOT NULL,
    cnpj VARCHAR(18) UNIQUE,
    inscricao_estadual VARCHAR(20),
    endereco TEXT,
    numero VARCHAR(10),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    cep VARCHAR(10),
    telefone VARCHAR(20),
    email VARCHAR(100),
    contato_nome VARCHAR(255),
    contato_telefone VARCHAR(20),
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Categorias de Produtos
CREATE TABLE IF NOT EXISTS categorias (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Marcas
CREATE TABLE IF NOT EXISTS marcas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(100) NOT NULL UNIQUE,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ======================== PRODUTOS =============================

CREATE TABLE IF NOT EXISTS produtos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sku VARCHAR(50) UNIQUE NOT NULL,
    codigo_barras VARCHAR(20) UNIQUE,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    categoria_id UUID REFERENCES categorias(id),
    marca_id UUID REFERENCES marcas(id),
    
    -- Preços
    preco_custo NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    preco_venda NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    preco_atacado NUMERIC(12,2),
    margem_lucro NUMERIC(5,2) DEFAULT 0.00, -- percentual
    
    -- Unidades
    unidade_medida_padrao unidade_medida DEFAULT 'UN',
    unidade_venda unidade_medida DEFAULT 'UN',
    quantidade_por_embalagem NUMERIC(10,2) DEFAULT 1.00,
    
    -- Estoque
    estoque_minimo NUMERIC(10,2) DEFAULT 0.00,
    estoque_maximo NUMERIC(10,2) DEFAULT 0.00,
    estoque_atual NUMERIC(10,2) DEFAULT 0.00,
    
    -- Controle
    ativo BOOLEAN DEFAULT true,
    requer_lote BOOLEAN DEFAULT false,
    controla_serie BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Lotes de Produtos
CREATE TABLE IF NOT EXISTS produto_lotes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    produto_id UUID NOT NULL REFERENCES produtos(id) ON DELETE CASCADE,
    numero_lote VARCHAR(50) NOT NULL,
    data_fabricacao DATE,
    data_vencimento DATE,
    quantidade NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    localizacao TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(produto_id, numero_lote)
);

-- ======================== CAIXA ============================

CREATE TABLE IF NOT EXISTS caixas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    numero INTEGER NOT NULL,
    descricao VARCHAR(100),
    serie_pdv VARCHAR(20),
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS movimentacoes_caixa (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    caixa_id UUID NOT NULL REFERENCES caixas(id),
    data_abertura TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    data_fechamento TIMESTAMP WITH TIME ZONE,
    operador_id UUID NOT NULL REFERENCES users(id),
    saldo_inicial NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    total_vendas NUMERIC(12,2) DEFAULT 0.00,
    total_dinheiro NUMERIC(12,2) DEFAULT 0.00,
    total_sangria NUMERIC(12,2) DEFAULT 0.00,
    total_suprimento NUMERIC(12,2) DEFAULT 0.00,
    saldo_final NUMERIC(12,2),
    status VARCHAR(20) DEFAULT 'ABERTA', -- ABERTA, FECHADA, CONFERIDO
    observacoes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ======================== VENDAS PDV ==========================

CREATE TABLE IF NOT EXISTS vendas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    numero_nf VARCHAR(20) UNIQUE NOT NULL, -- Gerado automaticamente PED-YYYYMMDD-XXXXXX
    caixa_id UUID NOT NULL REFERENCES caixas(id),
    movimentacao_caixa_id UUID NOT NULL REFERENCES movimentacoes_caixa(id),
    operador_id UUID NOT NULL REFERENCES users(id),
    cliente_id UUID REFERENCES clientes(id),
    
    -- Valores
    subtotal NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    desconto NUMERIC(12,2) DEFAULT 0.00,
    desconto_percentual NUMERIC(5,2) DEFAULT 0.00,
    acrescimo NUMERIC(12,2) DEFAULT 0.00,
    impostos NUMERIC(12,2) DEFAULT 0.00,
    total NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    
    -- Pagamento
    forma_pagamento pagamento_forma NOT NULL,
    valor_pago NUMERIC(12,2) NOT NULL,
    valor_troco NUMERIC(12,2) DEFAULT 0.00,
    
    -- Fiscal
    status_venda venda_status DEFAULT 'FINALIZADA',
    status_fiscal documento_fiscal_status DEFAULT 'SEM_DOCUMENTO_FISCAL',
    numero_nfce VARCHAR(50),
    numero_nfe VARCHAR(50),
    chave_acesso_nfce VARCHAR(50),
    chave_acesso_nfe VARCHAR(50),
    protocolo_nfce VARCHAR(50),
    protocolo_nfe VARCHAR(50),
    xml_nfce TEXT,
    xml_nfe TEXT,
    mensagem_erro_fiscal TEXT,
    
    -- Controle
    observacoes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_vendas_data ON vendas(created_at DESC);
CREATE INDEX idx_vendas_caixa ON vendas(caixa_id);
CREATE INDEX idx_vendas_cliente ON vendas(cliente_id);
CREATE INDEX idx_vendas_operador ON vendas(operador_id);
CREATE INDEX idx_vendas_fiscal_status ON vendas(status_fiscal);

-- Itens da Venda
CREATE TABLE IF NOT EXISTS vendas_itens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venda_id UUID NOT NULL REFERENCES vendas(id) ON DELETE CASCADE,
    produto_id UUID NOT NULL REFERENCES produtos(id),
    lote_id UUID REFERENCES produto_lotes(id),
    
    quantidade NUMERIC(10,2) NOT NULL,
    unidade_medida unidade_medida NOT NULL,
    preco_unitario NUMERIC(12,2) NOT NULL,
    subtotal NUMERIC(12,2) NOT NULL,
    desconto NUMERIC(12,2) DEFAULT 0.00,
    desconto_percentual NUMERIC(5,2) DEFAULT 0.00,
    acrescimo NUMERIC(12,2) DEFAULT 0.00,
    total NUMERIC(12,2) NOT NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_vendas_itens_venda ON vendas_itens(venda_id);
CREATE INDEX idx_vendas_itens_produto ON vendas_itens(produto_id);

-- ======================== ESTOQUE MOVIMENTAÇÃO ==========================

CREATE TABLE IF NOT EXISTS estoque_movimentacoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    produto_id UUID NOT NULL REFERENCES produtos(id),
    lote_id UUID REFERENCES produto_lotes(id),
    tipo_movimento VARCHAR(20) NOT NULL, -- ENTRADA, SAIDA, AJUSTE, DEVOLUCAO
    quantidade NUMERIC(10,2) NOT NULL,
    unidade_medida unidade_medida NOT NULL,
    preco_unitario NUMERIC(12,2),
    motivo TEXT,
    referencia_id UUID,
    referencia_tipo VARCHAR(50), -- 'VENDA', 'COMPRA', 'AJUSTE'
    usuario_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_estoque_mov_produto ON estoque_movimentacoes(produto_id);
CREATE INDEX idx_estoque_mov_data ON estoque_movimentacoes(created_at DESC);
CREATE INDEX idx_estoque_mov_tipo ON estoque_movimentacoes(tipo_movimento);

-- ======================== FORMAS DE PAGAMENTO ==========================

CREATE TABLE IF NOT EXISTS pagamentos_venda (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venda_id UUID NOT NULL REFERENCES vendas(id) ON DELETE CASCADE,
    forma pagamento_forma NOT NULL,
    valor NUMERIC(12,2) NOT NULL,
    numero_parcela INTEGER DEFAULT 1,
    total_parcelas INTEGER DEFAULT 1,
    data_vencimento DATE,
    status_pagamento VARCHAR(20) DEFAULT 'RECEBIDO', -- RECEBIDO, PENDENTE, CANCELADO
    observacoes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ======================== CONTAS A RECEBER ==========================

CREATE TABLE IF NOT EXISTS contas_receber (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venda_id UUID REFERENCES vendas(id),
    cliente_id UUID NOT NULL REFERENCES clientes(id),
    valor_original NUMERIC(12,2) NOT NULL,
    valor_pago NUMERIC(12,2) DEFAULT 0.00,
    valor_pendente NUMERIC(12,2) NOT NULL,
    data_vencimento DATE NOT NULL,
    data_pagamento DATE,
    juros NUMERIC(12,2) DEFAULT 0.00,
    multa NUMERIC(12,2) DEFAULT 0.00,
    desconto NUMERIC(12,2) DEFAULT 0.00,
    status_pagamento VARCHAR(20) DEFAULT 'ABERTO', -- ABERTO, PARCIAL, PAGO, CANCELADO
    observacoes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ======================== DOCUMENTOS FISCAIS ==========================

CREATE TABLE IF NOT EXISTS documentos_fiscais (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venda_id UUID NOT NULL REFERENCES vendas(id) ON DELETE CASCADE,
    tipo_documento VARCHAR(20) NOT NULL, -- NFCE, NFE, NFE_COMPLEMENTAR
    numero_documento VARCHAR(50),
    serie INTEGER,
    chave_acesso VARCHAR(50),
    protocolo_autorizacao VARCHAR(50),
    status_sefaz VARCHAR(50), -- AUTORIZADA, REJEITADA, CANCELADA, DENEGADA
    mensagem_sefaz TEXT,
    xml_nota TEXT,
    xml_retorno TEXT,
    valor_total NUMERIC(12,2),
    natureza_operacao VARCHAR(100),
    data_emissao TIMESTAMP WITH TIME ZONE,
    data_autorizacao TIMESTAMP WITH TIME ZONE,
    tentativas_emissao INTEGER DEFAULT 0,
    ultima_tentativa TIMESTAMP WITH TIME ZONE,
    proximo_retry TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_docs_fiscais_venda ON documentos_fiscais(venda_id);
CREATE INDEX idx_docs_fiscais_status ON documentos_fiscais(status_sefaz);

-- ======================== AUDITORIA ==========================

CREATE TABLE IF NOT EXISTS auditoria_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tabela_nome VARCHAR(100) NOT NULL,
    operacao VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    registro_id UUID,
    dados_antigos JSONB,
    dados_novos JSONB,
    usuario_id UUID REFERENCES users(id),
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_auditoria_tabela ON auditoria_log(tabela_nome);
CREATE INDEX idx_auditoria_usuario ON auditoria_log(usuario_id);
CREATE INDEX idx_auditoria_data ON auditoria_log(created_at DESC);

-- ======================== SEQUENCES ==========================

CREATE SEQUENCE IF NOT EXISTS vendas_numero_seq START 1001;

-- ======================== FUNCTIONS ==========================

-- Atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Gerar número de venda
CREATE OR REPLACE FUNCTION gerar_numero_venda()
RETURNS VARCHAR AS $$
BEGIN
    RETURN 'PED-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(nextval('vendas_numero_seq')::TEXT, 6, '0');
END;
$$ LANGUAGE plpgsql;

-- Atualizar estoque ao vender
CREATE OR REPLACE FUNCTION atualizar_estoque_venda()
RETURNS TRIGGER AS $$
BEGIN
    -- Reduzir estoque ao finalizar venda
    IF NEW.status_venda = 'FINALIZADA' AND OLD.status_venda != 'FINALIZADA' THEN
        UPDATE produtos SET estoque_atual = estoque_atual - (
            SELECT COALESCE(SUM(quantidade), 0) 
            FROM vendas_itens 
            WHERE venda_id = NEW.id
        )
        WHERE id IN (SELECT produto_id FROM vendas_itens WHERE venda_id = NEW.id);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Calcular saldo devedor cliente
CREATE OR REPLACE FUNCTION atualizar_saldo_cliente()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE clientes 
    SET saldo_devedor = (
        SELECT COALESCE(SUM(valor_pendente), 0) 
        FROM contas_receber 
        WHERE cliente_id = NEW.cliente_id 
        AND status_pagamento IN ('ABERTO', 'PARCIAL')
    )
    WHERE id = NEW.cliente_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ======================== TRIGGERS ==========================

CREATE TRIGGER update_empresa_config_updated_at
BEFORE UPDATE ON empresa_config
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clientes_updated_at
BEFORE UPDATE ON clientes
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_produtos_updated_at
BEFORE UPDATE ON produtos
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vendas_estoque
AFTER UPDATE ON vendas
FOR EACH ROW EXECUTE FUNCTION atualizar_estoque_venda();

CREATE TRIGGER update_contas_saldo_cliente
AFTER INSERT OR UPDATE ON contas_receber
FOR EACH ROW EXECUTE FUNCTION atualizar_saldo_cliente();

-- ======================== RLS (Row Level Security) ==========================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE estoque_movimentacoes ENABLE ROW LEVEL SECURITY;

CREATE POLICY users_read_own_data ON users
FOR SELECT USING (id = auth.uid() OR auth.jwt() ->> 'role' = 'ADMIN');

CREATE POLICY vendas_read_by_role ON vendas
FOR SELECT USING (
    auth.jwt() ->> 'role' IN ('ADMIN', 'GERENTE', 'OPERADOR_CAIXA')
    OR operador_id = auth.uid()
);

-- ======================== VIEWS ==========================

CREATE OR REPLACE VIEW v_vendas_do_dia AS
SELECT 
    CURRENT_DATE as data_venda,
    COUNT(DISTINCT id) as total_vendas,
    SUM(total) as valor_total,
    COUNT(DISTINCT cliente_id) as clientes_unicos,
    SUM(CASE WHEN status_venda = 'FINALIZADA' THEN total ELSE 0 END) as valor_vendas_finalizadas
FROM vendas
WHERE DATE(created_at) = CURRENT_DATE;

CREATE OR REPLACE VIEW v_estoque_critico AS
SELECT 
    p.id,
    p.sku,
    p.nome,
    p.marca_id,
    p.estoque_minimo,
    p.estoque_atual,
    CASE 
        WHEN p.estoque_atual < p.estoque_minimo THEN 'CRITICO'
        WHEN p.estoque_atual = 0 THEN 'ZERADO'
        ELSE 'OK'
    END as situacao
FROM produtos p
WHERE p.estoque_atual <= p.estoque_minimo;

CREATE OR REPLACE VIEW v_contas_receber_vencidas AS
SELECT 
    cr.id,
    cr.cliente_id,
    c.nome as cliente_nome,
    cr.valor_original,
    cr.valor_pendente,
    cr.data_vencimento,
    CURRENT_DATE - cr.data_vencimento as dias_atraso
FROM contas_receber cr
LEFT JOIN clientes c ON cr.cliente_id = c.id
WHERE cr.status_pagamento IN ('ABERTO', 'PARCIAL')
AND cr.data_vencimento < CURRENT_DATE
ORDER BY dias_atraso DESC;

-- ======================== DADOS INICIAIS ==========================

INSERT INTO categorias (nome) VALUES
    ('Bebidas Alcoólicas'),
    ('Refrigerantes'),
    ('Sucos'),
    ('Cervejas'),
    ('Destilados'),
    ('Vinhos'),
    ('Energéticos'),
    ('Água')
ON CONFLICT DO NOTHING;

INSERT INTO marcas (nome) VALUES
    ('Coca-Cola'),
    ('Pepsi'),
    ('Brahma'),
    ('Antartica'),
    ('Heineken'),
    ('Skol'),
    ('Itaipava'),
    ('Guaraná'),
    ('Fanta'),
    ('Sprite')
ON CONFLICT DO NOTHING;

INSERT INTO caixas (numero, descricao) VALUES
    (1, 'Caixa 1 - PDV Principal'),
    (2, 'Caixa 2 - PDV Secundário'),
    (3, 'Caixa 3 - Retirada')
ON CONFLICT DO NOTHING;

COMMIT;
