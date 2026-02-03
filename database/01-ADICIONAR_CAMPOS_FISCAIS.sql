-- ================================================================
-- ANÁLISE: CAMPOS FALTANTES PARA EMISSÃO DE DOCUMENTOS FISCAIS
-- ================================================================
-- Data: Fevereiro 3, 2026
-- Status: CRÍTICO - Faltam campos obrigatórios
-- ================================================================

-- ================================================================
-- ⚠️ PROBLEMAS IDENTIFICADOS
-- ================================================================

/*
1. TABELA PRODUTOS - FALTAM CAMPOS FISCAIS OBRIGATÓRIOS
   Campos necessários para emissão de NFC-e/NF-e:
   
   ❌ NCM (Nomenclatura Comum do Mercosul) - OBRIGATÓRIO
   ❌ CFOP (Código Fiscal de Operação e Prestação) - OBRIGATÓRIO
   ❌ Imposto ICMS (alíquota, situação tributária)
   ❌ Imposto PIS (alíquota)
   ❌ Imposto COFINS (alíquota)
   ❌ Imposto IPI (alíquota)
   ❌ Origem do produto (Importado/Nacional)
   ❌ Descrição para NFe (pode ser diferente da comercial)

2. TABELA EMPRESA_CONFIG - FALTAM DADOS CRÍTICOS
   ❌ Série da NFC-e (começa em 1, mas precisa estar preenchida)
   ❌ Número da NFC-e (começa em 1, precisa atualizar após cada emissão)
   ❌ Certificado digital (para assinatura do XML)
   ❌ Senha certificado
   ❌ Código CNAE (necessário para calular impostos)
   ❌ Regime tributário (ainda String genérica)
   ❌ Natureza da operação (mapeamento de CFOP)
   
3. EDGE FUNCTIONS (SUPABASE)
   ❌ Faltam implementações das funções Typescript
   ❌ Assinatura digital do XML
   ❌ Validação XSD do XML
   ❌ Integração com Focus NFe

4. TABELA DOCUMENTOS_FISCAIS
   ❌ Faltam campos de impostos por documento
   ❌ Falta campo de natureza da operação detalhada
   ❌ Falta tracking de tenativas/erros específicos
*/

-- ================================================================
-- ✅ SOLUÇÃO: ADICIONAR CAMPOS À TABELA PRODUTOS
-- ================================================================

ALTER TABLE produtos ADD COLUMN IF NOT EXISTS ncm VARCHAR(8) DEFAULT '22021000';
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS cfop VARCHAR(4) DEFAULT '5102';
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS origem_produto VARCHAR(1) DEFAULT '0'; -- 0=Nacional, 1=Importado
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS descricao_nfe TEXT; -- Para descrição diferente na nota

-- Campos de Impostos (percentuais)
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS aliquota_icms NUMERIC(5,2) DEFAULT 0.00;
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS aliquota_pis NUMERIC(5,2) DEFAULT 0.00;
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS aliquota_cofins NUMERIC(5,2) DEFAULT 0.00;
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS aliquota_ipi NUMERIC(5,2) DEFAULT 0.00;
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS cst_icms VARCHAR(3) DEFAULT '00'; -- Código Situação Tributária

-- ================================================================
-- ✅ SOLUÇÃO: COMPLEMENTAR TABELA EMPRESA_CONFIG
-- ================================================================

-- Adicionar campos que faltam
ALTER TABLE empresa_config ADD COLUMN IF NOT EXISTS certificado_digital TEXT;
ALTER TABLE empresa_config ADD COLUMN IF NOT EXISTS senha_certificado VARCHAR(255);
ALTER TABLE empresa_config ADD COLUMN IF NOT EXISTS regime_tributario_codigo VARCHAR(1); -- 1=Simples, 2=Lucro Real, 3=Lucro Presumido
ALTER TABLE empresa_config ADD COLUMN IF NOT EXISTS natureza_operacao_padrao VARCHAR(150) DEFAULT 'VENDA';
ALTER TABLE empresa_config ADD COLUMN IF NOT EXISTS sincronizar_numero_nfce BOOLEAN DEFAULT true; -- Auto-sincroniza com Focus
ALTER TABLE empresa_config ADD COLUMN IF NOT EXISTS ultimo_numero_nfce_sincronizado INTEGER DEFAULT 0;

-- ================================================================
-- 📊 TABELA COMPLEMENTAR: ALIQUOTAS PADRÃO POR CATEGORIA
-- ================================================================

CREATE TABLE IF NOT EXISTS categoria_impostos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    categoria_id UUID NOT NULL REFERENCES categorias(id) ON DELETE CASCADE,
    aliquota_icms NUMERIC(5,2) DEFAULT 0.00,
    aliquota_pis NUMERIC(5,2) DEFAULT 0.00,
    aliquota_cofins NUMERIC(5,2) DEFAULT 0.00,
    aliquota_ipi NUMERIC(5,2) DEFAULT 0.00,
    cst_icms VARCHAR(3) DEFAULT '00',
    ncm_padrao VARCHAR(8),
    cfop_padrao VARCHAR(4) DEFAULT '5102',
    origem_padrao VARCHAR(1) DEFAULT '0',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(categoria_id)
);

-- ================================================================
-- 📊 TABELA COMPLEMENTAR: ALIQUOTAS POR ESTADO
-- ================================================================

CREATE TABLE IF NOT EXISTS aliquotas_estaduais (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    estado_origem VARCHAR(2) NOT NULL,
    estado_destino VARCHAR(2) NOT NULL,
    categoria_id UUID REFERENCES categorias(id),
    aliquota_icms NUMERIC(5,2) DEFAULT 0.00,
    aliquota_pis NUMERIC(5,2) DEFAULT 0.00,
    aliquota_cofins NUMERIC(5,2) DEFAULT 0.00,
    vigencia_inicio DATE NOT NULL,
    vigencia_fim DATE,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(estado_origem, estado_destino, categoria_id, vigencia_inicio)
);

-- ================================================================
-- 📋 DADOS INICIAIS: ALIQUOTAS POR CATEGORIA
-- ================================================================

-- Para Bebidas (Cerveja - NCM 22021000)
INSERT INTO categoria_impostos (categoria_id, aliquota_icms, aliquota_pis, aliquota_cofins, aliquota_ipi, cst_icms, ncm_padrao, cfop_padrao, origem_padrao)
SELECT id, 7.00, 7.15, 32.85, 0.00, '00', '22021000', '5102', '0'
FROM categorias WHERE nome = 'Bebidas Alcoólicas'
ON CONFLICT DO NOTHING;

-- Para Refrigerantes (NCM 22021000)
INSERT INTO categoria_impostos (categoria_id, aliquota_icms, aliquota_pis, aliquota_cofins, aliquota_ipi, cst_icms, ncm_padrao, cfop_padrao, origem_padrao)
SELECT id, 7.00, 7.15, 32.85, 0.00, '00', '22021000', '5102', '0'
FROM categorias WHERE nome = 'Refrigerantes'
ON CONFLICT DO NOTHING;

-- Para Sucos (NCM 20091900)
INSERT INTO categoria_impostos (categoria_id, aliquota_icms, aliquota_pis, aliquota_cofins, aliquota_ipi, cst_icms, ncm_padrao, cfop_padrao, origem_padrao)
SELECT id, 7.00, 7.15, 32.85, 0.00, '00', '20091900', '5102', '0'
FROM categorias WHERE nome = 'Sucos'
ON CONFLICT DO NOTHING;

-- ================================================================
-- 🔧 FUNCTION: CALCULAR IMPOSTOS DO PRODUTO
-- ================================================================

CREATE OR REPLACE FUNCTION calcular_impostos_produto(
    p_produto_id UUID,
    p_estado_destino VARCHAR(2) DEFAULT NULL,
    p_quantidade NUMERIC DEFAULT 1.00,
    p_preco_unitario NUMERIC DEFAULT 0.00
)
RETURNS TABLE(
    aliquota_icms NUMERIC,
    aliquota_pis NUMERIC,
    aliquota_cofins NUMERIC,
    aliquota_ipi NUMERIC,
    valor_icms NUMERIC,
    valor_pis NUMERIC,
    valor_cofins NUMERIC,
    valor_ipi NUMERIC,
    valor_total_impostos NUMERIC
) AS $$
DECLARE
    v_empresa RECORD;
    v_produto RECORD;
    v_cat_imposto RECORD;
    v_aliq_icms NUMERIC;
    v_aliq_pis NUMERIC;
    v_aliq_cofins NUMERIC;
    v_aliq_ipi NUMERIC;
    v_base_calculo NUMERIC;
BEGIN
    -- Obter empresa
    SELECT * INTO v_empresa FROM empresa_config LIMIT 1;
    
    -- Obter produto
    SELECT * INTO v_produto FROM produtos WHERE id = p_produto_id;
    
    IF v_produto IS NULL THEN
        RAISE EXCEPTION 'Produto não encontrado';
    END IF;
    
    -- Obter alíquotas da categoria
    SELECT * INTO v_cat_imposto 
    FROM categoria_impostos 
    WHERE categoria_id = v_produto.categoria_id;
    
    -- Se não tiver alíquota da categoria, usar do produto
    IF v_cat_imposto IS NULL THEN
        v_aliq_icms := v_produto.aliquota_icms;
        v_aliq_pis := v_produto.aliquota_pis;
        v_aliq_cofins := v_produto.aliquota_cofins;
        v_aliq_ipi := v_produto.aliquota_ipi;
    ELSE
        v_aliq_icms := v_cat_imposto.aliquota_icms;
        v_aliq_pis := v_cat_imposto.aliquota_pis;
        v_aliq_cofins := v_cat_imposto.aliquota_cofins;
        v_aliq_ipi := v_cat_imposto.aliquota_ipi;
    END IF;
    
    -- Calcular base
    v_base_calculo := p_quantidade * p_preco_unitario;
    
    -- Retornar
    RETURN QUERY
    SELECT 
        v_aliq_icms,
        v_aliq_pis,
        v_aliq_cofins,
        v_aliq_ipi,
        ROUND((v_base_calculo * v_aliq_icms / 100), 2),
        ROUND((v_base_calculo * v_aliq_pis / 100), 2),
        ROUND((v_base_calculo * v_aliq_cofins / 100), 2),
        ROUND((v_base_calculo * v_aliq_ipi / 100), 2),
        ROUND((v_base_calculo * (v_aliq_icms + v_aliq_pis + v_aliq_cofins + v_aliq_ipi) / 100), 2);
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- 🔧 FUNCTION: VALIDAR DADOS PARA EMISSÃO FISCAL
-- ================================================================

CREATE OR REPLACE FUNCTION validar_dados_emissao_fiscal()
RETURNS TABLE(
    campo VARCHAR,
    status VARCHAR,
    mensagem TEXT
) AS $$
DECLARE
    v_empresa RECORD;
    v_problemas INT := 0;
BEGIN
    SELECT * INTO v_empresa FROM empresa_config LIMIT 1;
    
    -- Verificar empresa
    IF v_empresa IS NULL THEN
        RETURN QUERY SELECT 'empresa_config'::VARCHAR, 'ERRO'::VARCHAR, 'Nenhuma empresa configurada'::TEXT;
        v_problemas := v_problemas + 1;
    END IF;
    
    -- Verificar campos obrigatórios
    IF v_empresa.cnpj IS NULL OR v_empresa.cnpj = '' THEN
        RETURN QUERY SELECT 'empresa.cnpj'::VARCHAR, 'ERRO'::VARCHAR, 'CNPJ não preenchido'::TEXT;
        v_problemas := v_problemas + 1;
    END IF;
    
    IF v_empresa.inscricao_estadual IS NULL OR v_empresa.inscricao_estadual = '' THEN
        RETURN QUERY SELECT 'empresa.inscricao_estadual'::VARCHAR, 'ERRO'::VARCHAR, 'IE não preenchida'::TEXT;
        v_problemas := v_problemas + 1;
    END IF;
    
    IF v_empresa.logradouro IS NULL OR v_empresa.logradouro = '' THEN
        RETURN QUERY SELECT 'empresa.logradouro'::VARCHAR, 'ERRO'::VARCHAR, 'Logradouro não preenchido'::TEXT;
        v_problemas := v_problemas + 1;
    END IF;
    
    IF v_empresa.codigo_municipio IS NULL OR v_empresa.codigo_municipio = '' THEN
        RETURN QUERY SELECT 'empresa.codigo_municipio'::VARCHAR, 'ERRO'::VARCHAR, 'Código município IBGE não preenchido'::TEXT;
        v_problemas := v_problemas + 1;
    END IF;
    
    IF v_empresa.nfe_token IS NULL OR v_empresa.nfe_token = '' THEN
        RETURN QUERY SELECT 'empresa.nfe_token'::VARCHAR, 'AVISO'::VARCHAR, 'Token Focus NFe não configurado (emissão não funcionará)'::TEXT;
        v_problemas := v_problemas + 1;
    END IF;
    
    IF v_empresa.certificado_digital IS NULL OR v_empresa.certificado_digital = '' THEN
        RETURN QUERY SELECT 'empresa.certificado_digital'::VARCHAR, 'AVISO'::VARCHAR, 'Certificado digital não carregado'::TEXT;
        v_problemas := v_problemas + 1;
    END IF;
    
    -- Verificar produtos
    IF (SELECT COUNT(*) FROM produtos WHERE ncm IS NULL OR ncm = '') > 0 THEN
        RETURN QUERY SELECT 'produtos.ncm'::VARCHAR, 'AVISO'::VARCHAR, CONCAT((SELECT COUNT(*) FROM produtos WHERE ncm IS NULL OR ncm = ''), ' produtos sem NCM'::TEXT);
        v_problemas := v_problemas + 1;
    END IF;
    
    IF (SELECT COUNT(*) FROM produtos WHERE cfop IS NULL OR cfop = '') > 0 THEN
        RETURN QUERY SELECT 'produtos.cfop'::VARCHAR, 'AVISO'::VARCHAR, CONCAT((SELECT COUNT(*) FROM produtos WHERE cfop IS NULL OR cfop = ''), ' produtos sem CFOP'::TEXT);
        v_problemas := v_problemas + 1;
    END IF;
    
    -- Resultado final
    IF v_problemas = 0 THEN
        RETURN QUERY SELECT 'GERAL'::VARCHAR, 'OK'::VARCHAR, 'Sistema pronto para emissão fiscal'::TEXT;
    ELSE
        RETURN QUERY SELECT 'GERAL'::VARCHAR, 'CRÍTICO'::VARCHAR, CONCAT(v_problemas, ' problemas encontrados'::TEXT);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- ⚠️ DADOS A PREENCHEREM MANUALMENTE (VIA PÁGINA WEB)
-- ================================================================

/*
Em pages/configuracoes-empresa.html, preencher:

1. DADOS FISCAIS:
   □ CNPJ (XX.XXX.XXX/XXXX-XX)
   □ Inscricao Estadual
   □ Inscricao Municipal
   □ Razão Social
   □ Nome Fantasia
   □ Logradouro completo
   □ Número
   □ Bairro
   □ Cidade
   □ Estado
   □ CEP

2. CÓDIGO IBGE:
   □ Código Município (7 dígitos) - Consultar: https://www.ibge.gov.br/

3. REGIME TRIBUTÁRIO:
   □ Selecionar entre:
      - 1 = Simples Nacional
      - 2 = Lucro Real
      - 3 = Lucro Presumido

4. CNAE:
   □ Se bebidas: 4723700
   □ Consultar: https://concla.ibge.gov.br/

5. FOCUS NFe:
   □ Ambiente: 2 (Homologação) / 1 (Produção)
   □ Token de acesso (gerar no https://focusnfe.com.br/)
   □ Série NFC-e (ex: 1)
   □ Série NF-e (ex: 1)
   □ Número inicial NFC-e (ex: 1)
   □ Número inicial NF-e (ex: 1)

6. CERTIFICADO DIGITAL:
   □ Upload do arquivo .p12 ou .pfx
   □ Senha do certificado
   
7. NFC-e/NFe CONFIGURAÇÕES:
   □ Emitir NFC-e automaticamente
   □ Mensagem no cupom
   □ Limite de desconto máximo
   □ Permitir venda zerada
*/

-- ================================================================
-- 🎯 CHECKLIST PRÉ-IMPLEMENTAÇÃO
-- ================================================================

/*
CRÍTICO:
[ ] Preencher dados empresa em configuracoes-empresa.html
[ ] Configurar Código IBGE do município
[ ] Configurar token Focus NFe (gerar em https://focusnfe.com.br/)
[ ] Carregar certificado digital

IMPORTANTE:
[ ] Verificar NCM de cada categoria (usar planilha Focus)
[ ] Configurar alíquotas de impostos por categoria
[ ] Definir CFOP padrão (5102 para PDV - venda consumidor)
[ ] Testar emissão em ambiente de homologação

VALIDAÇÃO:
[ ] Executar: SELECT * FROM validar_dados_emissao_fiscal();
[ ] Deve retornar: "Sistema pronto para emissão fiscal"
[ ] Testar emissão de NFC-e com venda teste
*/

-- ================================================================
COMMIT;
