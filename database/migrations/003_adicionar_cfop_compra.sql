-- Adicionar TODAS as colunas que faltam na tabela produtos

-- IMPORTANTE: Alterar colunas existentes que têm tamanho insuficiente
ALTER TABLE produtos ALTER COLUMN ncm SET DATA TYPE VARCHAR(10);
ALTER TABLE produtos ALTER COLUMN cest SET DATA TYPE VARCHAR(10);
ALTER TABLE produtos ALTER COLUMN cfop_venda SET DATA TYPE VARCHAR(10);
ALTER TABLE produtos ALTER COLUMN cfop_compra SET DATA TYPE VARCHAR(10);
ALTER TABLE produtos ALTER COLUMN cst_icms SET DATA TYPE VARCHAR(10);
ALTER TABLE produtos ALTER COLUMN cst_pis SET DATA TYPE VARCHAR(10);
ALTER TABLE produtos ALTER COLUMN cst_cofins SET DATA TYPE VARCHAR(10);
ALTER TABLE produtos ALTER COLUMN cst_ipi SET DATA TYPE VARCHAR(10);
ALTER TABLE produtos ALTER COLUMN origem SET DATA TYPE VARCHAR(5);

-- Colunas básicas
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS sku VARCHAR(50) DEFAULT '';
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS categoria_id UUID REFERENCES categorias(id);
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS marca_id UUID REFERENCES marcas(id);
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS volume_ml INTEGER;
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS embalagem VARCHAR(50);
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS quantidade_embalagem INTEGER DEFAULT 1;

-- Controle de Validade
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS controla_validade BOOLEAN DEFAULT true;
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS dias_alerta_validade INTEGER DEFAULT 30;

-- Estoque
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS localizacao VARCHAR(50);

-- Preços
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS preco_custo DECIMAL(12,2) DEFAULT 0;
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS preco_venda DECIMAL(12,2) DEFAULT 0;

-- Colunas de classificação fiscal
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS ncm VARCHAR(10);
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS cest VARCHAR(10);

-- CFOP (Código Fiscal de Operação)
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS cfop_venda VARCHAR(10) DEFAULT '5102';
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS cfop_compra VARCHAR(10) DEFAULT '1102';

-- CST (Código de Situação Tributária)
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS cst_icms VARCHAR(10);
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS cst_pis VARCHAR(10);
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS cst_cofins VARCHAR(10);
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS cst_ipi VARCHAR(10);

-- Origem e Alíquotas
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS origem VARCHAR(5) DEFAULT '0';
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS aliquota_icms DECIMAL(5,2) DEFAULT 0;
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS aliquota_pis DECIMAL(5,4) DEFAULT 0;
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS aliquota_cofins DECIMAL(5,4) DEFAULT 0;
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS aliquota_ipi DECIMAL(5,2) DEFAULT 0;

-- Fornecedor e Imagem
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS fornecedor_id UUID REFERENCES fornecedores(id);
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS imagem_url TEXT;

-- Estoque mín/máx
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS estoque_minimo DECIMAL(12,3) DEFAULT 0;
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS estoque_maximo DECIMAL(12,3) DEFAULT 0;

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_produtos_categoria_id ON produtos(categoria_id);
CREATE INDEX IF NOT EXISTS idx_produtos_marca_id ON produtos(marca_id);
CREATE INDEX IF NOT EXISTS idx_produtos_ncm ON produtos(ncm);
CREATE INDEX IF NOT EXISTS idx_produtos_cest ON produtos(cest);
CREATE INDEX IF NOT EXISTS idx_produtos_cfop_venda ON produtos(cfop_venda);
CREATE INDEX IF NOT EXISTS idx_produtos_cfop_compra ON produtos(cfop_compra);
