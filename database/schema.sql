-- =====================================================
-- SCHEMA DO BANCO DE DADOS
-- Sistema PDV/ERP - Distribuidora
-- =====================================================
-- Data: 05/02/2026
-- Versão: 2.0.0
-- =====================================================
-- IMPORTANTE: Este arquivo contém APENAS as tabelas da aplicação
-- As tabelas do Supabase (auth, storage, realtime, vault) são criadas
-- automaticamente pelo Supabase e não devem ser recriadas.
-- =====================================================

-- ==================== TABELAS DO SISTEMA ====================

CREATE TABLE IF NOT EXISTS public.aliquotas_estaduais (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  estado_origem character varying NOT NULL,
  estado_destino character varying NOT NULL,
  categoria_id uuid,
  aliquota_icms numeric DEFAULT 0.00,
  aliquota_pis numeric DEFAULT 0.00,
  aliquota_cofins numeric DEFAULT 0.00,
  vigencia_inicio date NOT NULL,
  vigencia_fim date,
  ativo boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT aliquotas_estaduais_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.categorias (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  nome character varying NOT NULL UNIQUE,
  descricao text,
  ativo boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT categorias_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.marcas (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  nome character varying NOT NULL UNIQUE,
  ativo boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  descricao text,
  CONSTRAINT marcas_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.clientes (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  nome character varying NOT NULL,
  tipo character varying,
  cpf_cnpj character varying UNIQUE,
  inscricao_estadual character varying,
  endereco text,
  numero character varying,
  complemento text,
  bairro character varying,
  cidade character varying,
  estado character varying,
  cep character varying,
  telefone character varying,
  whatsapp character varying,
  email character varying,
  limite_credito numeric DEFAULT 0.00,
  saldo_devedor numeric DEFAULT 0.00,
  tabela_preco_custom boolean DEFAULT false,
  ativo boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT clientes_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.fornecedores (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  nome character varying NOT NULL,
  razao_social character varying NOT NULL,
  cnpj character varying UNIQUE,
  inscricao_estadual character varying,
  nome_fantasia character varying,
  endereco text,
  numero character varying,
  complemento character varying,
  bairro character varying,
  cidade character varying,
  estado character varying,
  cep character varying,
  telefone character varying,
  email character varying,
  contato_nome character varying,
  contato_telefone character varying,
  usuario_id uuid,
  site character varying,
  banco character varying,
  agencia character varying,
  conta character varying,
  pix character varying,
  observacoes text,
  ativo boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT fornecedores_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.produtos (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  codigo character varying,
  codigo_barras character varying UNIQUE,
  nome character varying NOT NULL,
  descricao text,
  categoria_id uuid,
  marca_id uuid,
  preco_custo numeric NOT NULL DEFAULT 0.00,
  preco_venda numeric NOT NULL DEFAULT 0.00,
  preco_atacado numeric,
  margem_lucro numeric DEFAULT 0.00,
  unidade_medida_padrao character varying DEFAULT 'UN',
  unidade_venda character varying DEFAULT 'UN',
  quantidade_por_embalagem numeric DEFAULT 1.00,
  estoque_minimo numeric DEFAULT 0.00,
  estoque_maximo numeric DEFAULT 0.00,
  estoque_atual numeric DEFAULT 0.00,
  ativo boolean DEFAULT true,
  requer_lote boolean DEFAULT false,
  controla_serie boolean DEFAULT false,
  ncm character varying DEFAULT '22021000',
  cfop character varying DEFAULT '5102',
  cfop_compra character varying DEFAULT '1102',
  cfop_venda character varying DEFAULT '5102',
  origem_produto character varying DEFAULT '0',
  origem character varying DEFAULT '0',
  descricao_nfe text,
  aliquota_icms numeric DEFAULT 0.00,
  aliquota_pis numeric DEFAULT 0.00,
  aliquota_cofins numeric DEFAULT 0.00,
  aliquota_ipi numeric DEFAULT 0.00,
  cst_icms character varying DEFAULT '00',
  cst_pis character varying,
  cst_cofins character varying,
  cst_ipi character varying,
  cest character varying,
  marca character varying,
  unidade character varying DEFAULT 'UN',
  fornecedor_id uuid,
  imagem_url text,
  volume_ml integer,
  controla_validade boolean DEFAULT true,
  embalagem character varying,
  quantidade_embalagem integer DEFAULT 1,
  dias_alerta_validade integer DEFAULT 30,
  localizacao character varying,
  peso_kg numeric,
  sku character varying,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT produtos_pkey PRIMARY KEY (id),
  CONSTRAINT produtos_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categorias(id),
  CONSTRAINT produtos_marca_id_fkey FOREIGN KEY (marca_id) REFERENCES public.marcas(id)
);

CREATE TABLE IF NOT EXISTS public.users (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  email character varying NOT NULL UNIQUE,
  nome_completo character varying NOT NULL,
  full_name character varying,
  cpf character varying UNIQUE,
  role character varying NOT NULL DEFAULT 'VENDEDOR',
  telefone character varying,
  whatsapp character varying,
  ativo boolean DEFAULT true,
  email_confirmado boolean DEFAULT false,
  ultimo_login timestamp with time zone,
  senha_hash character varying,
  approved boolean DEFAULT false,
  approved_by uuid,
  approved_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT users_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.caixas (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  numero integer NOT NULL UNIQUE,
  nome character varying,
  descricao character varying,
  serie_pdv character varying,
  impressora_nfce character varying,
  impressora_cupom character varying,
  terminal character varying,
  ativo boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT caixas_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.caixa_sessoes (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  caixa_id uuid,
  operador_id uuid,
  data_abertura timestamp with time zone DEFAULT now(),
  data_fechamento timestamp with time zone,
  valor_abertura numeric DEFAULT 0,
  valor_fechamento numeric,
  valor_vendas numeric DEFAULT 0,
  valor_sangrias numeric DEFAULT 0,
  valor_suprimentos numeric DEFAULT 0,
  diferenca numeric,
  status character varying DEFAULT 'ABERTO' CHECK (status IN ('ABERTO', 'FECHADO', 'CONFERIDO')),
  observacoes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT caixa_sessoes_pkey PRIMARY KEY (id),
  CONSTRAINT fk_caixa_sessoes_caixa FOREIGN KEY (caixa_id) REFERENCES public.caixas(id),
  CONSTRAINT fk_caixa_sessoes_operador FOREIGN KEY (operador_id) REFERENCES public.users(id)
);

CREATE TABLE IF NOT EXISTS public.vendas (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  numero character varying,
  numero_nf character varying UNIQUE,
  caixa_id uuid NOT NULL,
  movimentacao_caixa_id uuid NOT NULL,
  operador_id uuid NOT NULL,
  cliente_id uuid,
  subtotal numeric NOT NULL DEFAULT 0.00,
  desconto numeric DEFAULT 0.00,
  desconto_percentual numeric DEFAULT 0.00,
  desconto_valor numeric DEFAULT 0,
  acrescimo numeric DEFAULT 0.00,
  impostos numeric DEFAULT 0.00,
  total numeric NOT NULL DEFAULT 0.00,
  forma_pagamento character varying NOT NULL,
valor_pago numeric NOT NULL,
  valor_troco numeric DEFAULT 0.00,
  troco numeric DEFAULT 0,
  status character varying DEFAULT 'FINALIZADA',
  status_venda character varying DEFAULT 'FINALIZADA',
  status_fiscal character varying DEFAULT 'SEM_DOCUMENTO_FISCAL',
  numero_nfce character varying,
  numero_nfe character varying,
  chave_acesso_nfce character varying,
  chave_acesso_nfe character varying,
  protocolo_nfce character varying,
  protocolo_nfe character varying,
  xml_nfce text,
  xml_nfe text,
  mensagem_erro_fiscal text,
  observacoes text,
  data_venda timestamp with time zone DEFAULT now(),
  sessao_id uuid,
  vendedor_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT vendas_pkey PRIMARY KEY (id),
  CONSTRAINT vendas_movimentacao_caixa_id_fkey FOREIGN KEY (movimentacao_caixa_id) REFERENCES public.caixa_sessoes(id),
  CONSTRAINT vendas_caixa_id_fkey FOREIGN KEY (caixa_id) REFERENCES public.caixas(id),
  CONSTRAINT vendas_operador_id_fkey FOREIGN KEY (operador_id) REFERENCES public.users(id),
  CONSTRAINT vendas_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id)
);

CREATE TABLE IF NOT EXISTS public.produto_lotes (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  produto_id uuid NOT NULL,
  numero_lote character varying NOT NULL,
  data_fabricacao date,
  data_vencimento date,
  data_validade date,
  quantidade numeric NOT NULL DEFAULT 0.00,
  quantidade_inicial numeric DEFAULT 0,
  quantidade_atual numeric DEFAULT 0,
  preco_custo numeric DEFAULT 0,
  fornecedor_id uuid,
  nota_fiscal character varying,
  localizacao text,
  observacoes text,
  status character varying DEFAULT 'ATIVO',
  ativo boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT produto_lotes_pkey PRIMARY KEY (id),
  CONSTRAINT produto_lotes_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES public.produtos(id)
);

CREATE TABLE IF NOT EXISTS public.venda_itens (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  venda_id uuid NOT NULL,
  produto_id uuid NOT NULL,
  lote_id uuid,
  quantidade numeric NOT NULL,
  preco_unitario numeric NOT NULL,
  desconto_percentual numeric DEFAULT 0,
  desconto_valor numeric DEFAULT 0,
  subtotal numeric NOT NULL,
  cfop character varying,
  ncm character varying,
  cst_icms character varying,
  valor_icms numeric DEFAULT 0,
  preco_custo numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT venda_itens_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.vendas_itens (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  venda_id uuid NOT NULL,
  produto_id uuid NOT NULL,
  lote_id uuid,
  quantidade numeric NOT NULL,
  unidade_medida character varying NOT NULL,
  preco_unitario numeric NOT NULL,
  subtotal numeric NOT NULL,
  desconto numeric DEFAULT 0.00,
  desconto_percentual numeric DEFAULT 0.00,
  acrescimo numeric DEFAULT 0.00,
  total numeric NOT NULL,
  preco_custo numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT vendas_itens_pkey PRIMARY KEY (id),
  CONSTRAINT vendas_itens_venda_id_fkey FOREIGN KEY (venda_id) REFERENCES public.vendas(id),
  CONSTRAINT vendas_itens_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES public.produtos(id),
  CONSTRAINT vendas_itens_lote_id_fkey FOREIGN KEY (lote_id) REFERENCES public.produto_lotes(id)
);

CREATE TABLE IF NOT EXISTS public.pedidos_compra (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  numero character varying NOT NULL UNIQUE,
  fornecedor_id uuid NOT NULL,
  usuario_id uuid NOT NULL,
  subtotal numeric DEFAULT 0,
  desconto numeric DEFAULT 0,
  frete numeric DEFAULT 0,
  outras_despesas numeric DEFAULT 0,
  total numeric DEFAULT 0,
  data_pedido date DEFAULT CURRENT_DATE,
  data_previsao date,
  data_recebimento date,
  nf_numero character varying,
  nf_serie character varying,
  nf_chave character varying,
  status character varying DEFAULT 'PENDENTE' CHECK (status IN ('PENDENTE', 'APROVADO', 'RECEBIDO', 'CANCELADO')),
  observacoes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT pedidos_compra_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.pedido_compra_itens (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  pedido_id uuid NOT NULL,
  produto_id uuid NOT NULL,
  quantidade numeric NOT NULL,
  quantidade_recebida numeric DEFAULT 0,
  preco_unitario numeric NOT NULL,
  subtotal numeric NOT NULL,
  numero_lote character varying,
  data_validade date,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT pedido_compra_itens_pkey PRIMARY KEY (id),
  CONSTRAINT pedido_compra_itens_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES public.pedidos_compra(id)
);

CREATE TABLE IF NOT EXISTS public.estoque_movimentacoes (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  produto_id uuid NOT NULL,
  lote_id uuid,
  tipo_movimento character varying NOT NULL,
  quantidade numeric NOT NULL,
  unidade_medida character varying NOT NULL,
  preco_unitario numeric,
  motivo text,
  referencia_id uuid,
  referencia_tipo character varying,
  usuario_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT estoque_movimentacoes_pkey PRIMARY KEY (id),
  CONSTRAINT estoque_movimentacoes_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES public.produtos(id),
  CONSTRAINT estoque_movimentacoes_lote_id_fkey FOREIGN KEY (lote_id) REFERENCES public.produto_lotes(id),
  CONSTRAINT estoque_movimentacoes_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.users(id)
);

CREATE TABLE IF NOT EXISTS public.contas_pagar (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  numero_documento character varying,
  descricao character varying NOT NULL,
  fornecedor_id uuid,
  pedido_compra_id uuid,
  valor_original numeric NOT NULL,
  valor_desconto numeric DEFAULT 0,
  valor_juros numeric DEFAULT 0,
  valor_multa numeric DEFAULT 0,
  valor_pago numeric DEFAULT 0,
  data_emissao date DEFAULT CURRENT_DATE,
  data_vencimento date NOT NULL,
  data_pagamento date,
  forma_pagamento character varying,
  conta_bancaria character varying,
  status character varying DEFAULT 'PENDENTE' CHECK (status IN ('PENDENTE', 'PAGO', 'PAGO_PARCIAL', 'VENCIDO', 'CANCELADO')),
  categoria character varying DEFAULT 'FORNECEDOR',
  centro_custo character varying,
  parcela_atual integer DEFAULT 1,
  total_parcelas integer DEFAULT 1,
  observacoes text,
  usuario_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT contas_pagar_pkey PRIMARY KEY (id),
  CONSTRAINT contas_pagar_fornecedor_id_fkey FOREIGN KEY (fornecedor_id) REFERENCES public.fornecedores(id),
  CONSTRAINT contas_pagar_pedido_compra_id_fkey FOREIGN KEY (pedido_compra_id) REFERENCES public.pedidos_compra(id)
);

CREATE TABLE IF NOT EXISTS public.contas_receber (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  numero_documento character varying,
  descricao character varying,
  venda_id uuid,
  cliente_id uuid NOT NULL,
  valor_original numeric NOT NULL,
  valor_desconto numeric DEFAULT 0,
  valor_juros numeric DEFAULT 0,
  valor_multa numeric DEFAULT 0,
  valor_pago numeric DEFAULT 0,
  valor_recebido numeric DEFAULT 0,
  data_emissao date DEFAULT CURRENT_DATE,
  data_vencimento date NOT NULL,
  data_recebimento date,
  data_pagamento date,
  forma_recebimento character varying,
  forma_pagamento character varying,
  conta_bancaria character varying,
  status character varying DEFAULT 'PENDENTE' CHECK (status IN ('PENDENTE', 'RECEBIDO', 'PAGO', 'PAGO_PARCIAL', 'VENCIDO', 'CANCELADO')),
  categoria character varying DEFAULT 'VENDA',
  parcela_atual integer DEFAULT 1,
  total_parcelas integer DEFAULT 1,
  observacoes text,
  usuario_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT contas_receber_pkey PRIMARY KEY (id),
  CONSTRAINT contas_receber_venda_id_fkey FOREIGN KEY (venda_id) REFERENCES public.vendas(id),
  CONSTRAINT contas_receber_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id)
);

CREATE TABLE IF NOT EXISTS public.empresa_config (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  nome_empresa character varying NOT NULL,
  razao_social character varying,
  cnpj character varying UNIQUE,
  inscricao_estadual character varying,
  inscricao_municipal character varying,
  logo_url text,
  endereco text,
  logradouro character varying,
  numero character varying,
  endereco_numero character varying,
  complemento text,
  bairro character varying,
  cidade character varying,
  estado character varying,
  cep character varying,
  codigo_municipio character varying,
  telefone character varying,
  email character varying,
  website character varying,
  regime_tributario character varying,
  regime_tributario_codigo character varying,
  cnae character varying,
  natureza_operacao_padrao character varying DEFAULT 'VENDA',
  nfe_ambiente character varying DEFAULT '2',
  ambiente_nfe character varying DEFAULT '2',
  nfe_token text,
  focusnfe_token text,
  focusnfe_ambiente integer DEFAULT 2,
  nfce_serie integer DEFAULT 1,
  serie_nfe character varying DEFAULT '1',
  nfe_serie integer DEFAULT 1,
  nfce_numero integer DEFAULT 1,
  nfe_numero integer DEFAULT 1,
  proximo_numero_nfe integer DEFAULT 1,
  sincronizar_numero_nfce boolean DEFAULT true,
  ultimo_numero_nfce_sincronizado integer DEFAULT 0,
  csc_id character varying,
  csc_token character varying,
  certificado_digital text,
  certificado_validade date,
  senha_certificado character varying,
  pdv_emitir_nfce boolean DEFAULT false,
  pdv_emitir_nfce_automatico boolean DEFAULT false,
  habilitar_nfce boolean DEFAULT false,
  habilitar_cupom_fiscal boolean DEFAULT false,
  pdv_imprimir_cupom boolean DEFAULT true,
  pdv_permitir_venda_zerado boolean DEFAULT false,
  pdv_desconto_maximo boolean DEFAULT false,
  pdv_desconto_limite numeric DEFAULT 10.00,
  pdv_mensagem_cupom text,
  alerta_estoque_minimo boolean DEFAULT true,
  dias_alerta_validade integer DEFAULT 30,
  cor_primaria character varying DEFAULT '#3B82F6',
  cor_secundaria character varying DEFAULT '#10B981',
  whatsapp_api_provider character varying,
  whatsapp_numero_origem character varying,
  whatsapp_api_url text,
  whatsapp_api_key text,
  whatsapp_instance_id character varying,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT empresa_config_pkey PRIMARY KEY (id)
);

-- =====================================================
-- MELHORIAS E ATUALIZAÇÕES DO SISTEMA
-- =====================================================
-- Data: 05/02/2026
-- Versão: 2.0.0
--
-- Melhorias implementadas:
-- 1. Validação de estoque negativo
-- 2. Campos fiscais obrigatórios para NFC-e
-- 3. Índices de performance
-- 4. Views de análise financeira
-- 5. Triggers de auditoria
-- =====================================================

-- =====================================================
-- FUNÇÃO: Validar estoque negativo
-- =====================================================
CREATE OR REPLACE FUNCTION validar_estoque_positivo()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.estoque_atual < 0 THEN
        RAISE EXCEPTION 'Estoque não pode ser negativo para o produto %', NEW.nome;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger para validar estoque
DROP TRIGGER IF EXISTS trigger_validar_estoque ON produtos;
CREATE TRIGGER trigger_validar_estoque
BEFORE UPDATE ON produtos
FOR EACH ROW
EXECUTE FUNCTION validar_estoque_positivo();

-- =====================================================
-- COMENTÁRIOS DE DOCUMENTAÇÃO
-- =====================================================

COMMENT ON COLUMN produtos.preco_custo IS 'Preço de custo - atualizado automaticamente na entrada de compra';
COMMENT ON COLUMN produtos.estoque_atual IS 'Estoque atual - NUNCA editar manualmente, apenas via movimentações';
COMMENT ON COLUMN venda_itens.preco_custo IS 'Preço de custo no momento da venda - usado para análise de lucro';
COMMENT ON COLUMN vendas_itens.preco_custo IS 'Preço de custo no momento da venda - usado para análise de lucro';

COMMENT ON TABLE estoque_movimentacoes IS 'Registro de TODAS as movimentações de estoque - entrada, saída, ajustes';
COMMENT ON TABLE produtos IS 'Cadastro de produtos - estoque_atual é calculado, NÃO editar manualmente';

-- =====================================================
-- ÍNDICES DE PERFORMANCE
-- =====================================================

-- Índices para estoque_movimentacoes
CREATE INDEX IF NOT EXISTS idx_estoque_mov_produto ON estoque_movimentacoes(produto_id);
CREATE INDEX IF NOT EXISTS idx_estoque_mov_tipo ON estoque_movimentacoes(tipo_movimento);
CREATE INDEX IF NOT EXISTS idx_estoque_mov_created ON estoque_movimentacoes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_estoque_mov_referencia ON estoque_movimentacoes(referencia_id, referencia_tipo);

-- Índices para produtos
CREATE INDEX IF NOT EXISTS idx_produtos_codigo ON produtos(codigo);
CREATE INDEX IF NOT EXISTS idx_produtos_codigo_barras ON produtos(codigo_barras);
CREATE INDEX IF NOT EXISTS idx_produtos_nome ON produtos USING gin(to_tsvector('portuguese', nome));

-- Índices para vendas
CREATE INDEX IF NOT EXISTS idx_vendas_created ON vendas(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_vendas_cliente ON vendas(cliente_id);

-- Índices para pedidos_compra
CREATE INDEX IF NOT EXISTS idx_pedidos_compra_fornecedor ON pedidos_compra(fornecedor_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_compra_status ON pedidos_compra(status);

-- Índices para contas_pagar
CREATE INDEX IF NOT EXISTS idx_contas_pagar_fornecedor ON contas_pagar(fornecedor_id);
CREATE INDEX IF NOT EXISTS idx_contas_pagar_status ON contas_pagar(status);
CREATE INDEX IF NOT EXISTS idx_contas_pagar_vencimento ON contas_pagar(data_vencimento);

-- Índices para contas_receber
CREATE INDEX IF NOT EXISTS idx_contas_receber_cliente ON contas_receber(cliente_id);
CREATE INDEX IF NOT EXISTS idx_contas_receber_status ON contas_receber(status);
CREATE INDEX IF NOT EXISTS idx_contas_receber_vencimento ON contas_receber(data_vencimento);

-- =====================================================
-- VIEWS DE ANÁLISE
-- =====================================================

-- View: Análise Financeira de Vendas
CREATE OR REPLACE VIEW vw_analise_vendas AS
SELECT 
    v.id as venda_id,
    v.numero,
    v.created_at as data_venda,
    v.total as total_venda,
    c.nome as cliente_nome,
    u.nome_completo as operador_nome,
    COALESCE(SUM(vi.quantidade * vi.preco_custo), 0) as custo_total,
    v.total - COALESCE(SUM(vi.quantidade * vi.preco_custo), 0) as lucro_bruto,
    CASE 
        WHEN COALESCE(SUM(vi.quantidade * vi.preco_custo), 0) > 0 
        THEN ((v.total - COALESCE(SUM(vi.quantidade * vi.preco_custo), 0)) / COALESCE(SUM(vi.quantidade * vi.preco_custo), 1) * 100)
        ELSE 0 
    END as margem_lucro_percentual
FROM vendas v
LEFT JOIN venda_itens vi ON vi.venda_id = v.id
LEFT JOIN clientes c ON c.id = v.cliente_id
LEFT JOIN users u ON u.id = v.operador_id
WHERE v.status = 'FINALIZADA' OR v.status_venda = 'FINALIZADA'
GROUP BY v.id, v.numero, v.created_at, v.total, c.nome, u.nome_completo;

-- View: Posição de Estoque
CREATE OR REPLACE VIEW vw_posicao_estoque AS
SELECT 
    p.id,
    p.codigo,
    p.codigo_barras,
    p.nome,
    p.estoque_atual,
    p.estoque_minimo,
    p.estoque_maximo,
    p.preco_custo,
    p.preco_venda,
    p.unidade,
    c.nome as categoria,
    m.nome as marca,
    CASE 
        WHEN p.estoque_atual <= 0 THEN 'SEM_ESTOQUE'
        WHEN p.estoque_atual <= p.estoque_minimo THEN 'ESTOQUE_BAIXO'
        WHEN p.estoque_atual >= p.estoque_maximo THEN 'ESTOQUE_ALTO'
        ELSE 'ESTOQUE_NORMAL'
    END as status_estoque,
    p.estoque_atual * p.preco_custo as valor_estoque,
    p.created_at,
    p.updated_at
FROM produtos p
LEFT JOIN categorias c ON c.id = p.categoria_id
LEFT JOIN marcas m ON m.id = p.marca_id
WHERE p.ativo = true
ORDER BY p.nome;

-- View: Contas a Receber Vencidas
CREATE OR REPLACE VIEW v_contas_receber_vencidas AS
SELECT 
    cr.*,
    c.nome as cliente_nome,
    c.cpf_cnpj as cliente_documento,
    c.telefone as cliente_telefone,
    CURRENT_DATE - cr.data_vencimento as dias_atraso
FROM contas_receber cr
LEFT JOIN clientes c ON c.id = cr.cliente_id
WHERE cr.status IN ('PENDENTE', 'PAGO_PARCIAL')
AND cr.data_vencimento < CURRENT_DATE
ORDER BY cr.data_vencimento ASC;

-- View: Contas a Pagar Vencidas
CREATE OR REPLACE VIEW v_contas_pagar_vencidas AS
SELECT 
    cp.*,
    f.nome as fornecedor_nome,
    f.razao_social as fornecedor_razao_social,
    f.cnpj as fornecedor_cnpj,
    CURRENT_DATE - cp.data_vencimento as dias_atraso
FROM contas_pagar cp
LEFT JOIN fornecedores f ON f.id = cp.fornecedor_id
WHERE cp.status IN ('PENDENTE', 'PAGO_PARCIAL')
AND cp.data_vencimento < CURRENT_DATE
ORDER BY cp.data_vencimento ASC;

-- =====================================================
-- FIM DO SCHEMA
-- =====================================================
