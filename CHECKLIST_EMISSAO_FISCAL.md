# 📋 CHECKLIST EMISSÃO DE DOCUMENTOS FISCAIS

## ⚠️ Status: CRÍTICO - Campos Faltantes

Seu sistema está **90% pronto** para emissão fiscal, mas faltam campos obrigatórios para que funcione completamente.

---

## 🔴 CRÍTICO: O QUE FALTA

### 1. TABELA PRODUTOS
**Status:** ❌ Campos não existem

Campos OBRIGATÓRIOS que precisam ser adicionados:

| Campo | Tipo | Descrição | Exemplo |
|-------|------|-----------|---------|
| `ncm` | VARCHAR(8) | Nomenclatura Comum do Mercosul | 22021000 |
| `cfop` | VARCHAR(4) | Código Fiscal Operação | 5102 |
| `aliquota_icms` | NUMERIC | % ICMS | 7.00 |
| `aliquota_pis` | NUMERIC | % PIS | 7.15 |
| `aliquota_cofins` | NUMERIC | % COFINS | 32.85 |
| `aliquota_ipi` | NUMERIC | % IPI | 0.00 |
| `cst_icms` | VARCHAR(3) | Situação Tributária | 00 |
| `origem_produto` | VARCHAR(1) | 0=Nacional, 1=Importado | 0 |
| `descricao_nfe` | TEXT | Descrição para nota (opcional) | - |

**Ação:** Executar `01-ADICIONAR_CAMPOS_FISCAIS.sql`

---

### 2. TABELA EMPRESA_CONFIG
**Status:** ⚠️ Campos incompletos/vazios

Campos que precisam ser **preenchidos manualmente**:

| Campo | Status | Ação |
|-------|--------|------|
| `cnpj` | ❌ Vazio | Preencher em Configurações |
| `inscricao_estadual` | ❌ Vazio | Preencher em Configurações |
| `logradouro` | ❌ Vazio | Preencher endereço completo |
| `numero` | ❌ Vazio | Preencher número |
| `bairro` | ❌ Vazio | Preencher bairro |
| `cidade` | ❌ Vazio | Preencher cidade |
| `estado` | ❌ Vazio | Selecionar UF |
| `cep` | ❌ Vazio | Preencher CEP |
| `codigo_municipio` | ❌ CRÍTICO | Código IBGE (7 dígitos) |
| `cnae` | ❌ CRÍTICO | Código CNAE |
| `regime_tributario` | ❌ Vazio | 1, 2 ou 3 |
| `nfe_token` | ❌ CRÍTICO | Token Focus NFe |
| `certificado_digital` | ❌ CRÍTICO | Upload arquivo .p12 |
| `senha_certificado` | ❌ CRÍTICO | Senha certificado |

---

### 3. DADOS QUE PRECISAM SER CONFIGURADOS

#### 📍 Código Município (IBGE)
```
Necessário para: Localização da empresa na NF-e
Onde encontrar: https://www.ibge.gov.br/
Formato: 7 dígitos
Exemplo (São Paulo capital): 3550308
```

#### 🏭 Código CNAE
```
Necessário para: Classificação da atividade
Para Bebidas: 4723700 (Comércio varejista de bebidas em geral)
Consultar: https://concla.ibge.gov.br/
```

#### 🔑 Focus NFe Token
```
Necessário para: Emissão de NFC-e/NF-e
Gerar em: https://focusnfe.com.br/
Ambiente: 2 (Homologação) para testes
Ambiente: 1 (Produção) para real
```

#### 📜 Certificado Digital
```
Necessário para: Assinatura digital do XML
Formato: Arquivo .p12 ou .pfx
Senha: Memorizar antes de carregar
Validade: Consultar data expiração
```

---

## ✅ COMO RESOLVER

### Step 1: Executar Script SQL
```sql
-- Copie e execute no Supabase SQL Editor:
-- Arquivo: database/01-ADICIONAR_CAMPOS_FISCAIS.sql

-- Incluirá:
-- ✓ Campos em PRODUTOS (NCM, CFOP, impostos)
-- ✓ Campos em EMPRESA_CONFIG (certificado, token)
-- ✓ Tabela categoria_impostos (alíquotas por categoria)
-- ✓ Tabela aliquotas_estaduais (alíquotas por UF)
-- ✓ Function calcular_impostos_produto()
-- ✓ Function validar_dados_emissao_fiscal()
```

### Step 2: Preencher Dados da Empresa
**Arquivo:** `pages/configuracoes-empresa.html`

```
Seção: DADOS FISCAIS
□ CNPJ (XX.XXX.XXX/XXXX-XX)
□ Razão Social
□ Inscrição Estadual
□ Logradouro
□ Número / Complemento
□ Bairro / Cidade / Estado / CEP

Seção: CONFIGURAÇÃO FISCAL
□ Código Município IBGE ⚠️ CRÍTICO
□ CNAE ⚠️ CRÍTICO
□ Regime Tributário (Simples/Lucro Real/Presumido)

Seção: FOCUS NFE
□ Ambiente (2=Homologação, 1=Produção)
□ Token ⚠️ CRÍTICO
□ Série NFC-e (padrão: 1)
□ Série NF-e (padrão: 1)
□ Número inicial NFC-e (padrão: 1)
□ Número inicial NF-e (padrão: 1)

Seção: CERTIFICADO DIGITAL
□ Upload arquivo .p12/.pfx ⚠️ CRÍTICO
□ Senha ⚠️ CRÍTICO
```

### Step 3: Configurar Alíquotas por Categoria

```sql
-- As alíquotas padrão já vêm no script, mas você pode ajustar:

-- Para bebidas alcoólicas:
UPDATE categoria_impostos 
SET aliquota_icms = 7.00,
    aliquota_pis = 7.15,
    aliquota_cofins = 32.85,
    ncm_padrao = '22021000',
    cfop_padrao = '5102'
WHERE categoria_id = (SELECT id FROM categorias WHERE nome = 'Bebidas Alcoólicas');
```

### Step 4: Validar Dados

```sql
-- Execute para verificar se tudo está pronto:
SELECT * FROM validar_dados_emissao_fiscal();

-- Esperado: "Sistema pronto para emissão fiscal"
```

### Step 5: Testar Emissão

1. Abrir: `pages/pdv.html`
2. Fazer login como OPERADOR_CAIXA
3. Abrir caixa
4. Criar venda teste
5. Finalizar venda
6. Clicar em "Emitir NFC-e"
7. Verificar resultado

---

## 🎯 MAPEAMENTO: O QUE CADA CAMPO AFETA

### Emissão de NFC-e (Consumidor)
```
Necessários:
✓ empresa.cnpj, razao_social, logradouro
✓ empresa.codigo_municipio (IBGE)
✓ empresa.nfce_serie, nfce_numero
✓ empresa.certificado_digital + senha
✓ empresa.nfe_token (Focus)

✓ produto.ncm (Nomenclatura produto)
✓ produto.cfop (5102 = Venda PDV)
✓ produto.aliquota_icms (cálculo de impostos)
```

### Emissão de NF-e (B2B)
```
Mesmo que acima, MAIS:
✓ cliente.tipo = 'PJ'
✓ cliente.cpf_cnpj
✓ cliente.inscricao_estadual
✓ cliente.endereco completo

✓ produto.descricao_nfe (descrição detalhada)
✓ produto.origem_produto (nacional/importado)
```

### Cálculo de Impostos
```
Influenciam em:
✓ Valor total da venda (subtrai impostos ou não)
✓ Preço final mostrado no cupom
✓ Dados no XML enviado para SEFAZ
✓ Validação pelo fiscal

Alíquotas usadas na ordem:
1. categoria_impostos (se existir)
2. produto.aliquota_* (se categoria não tiver)
3. Padrão: 0% (nenhum imposto)
```

---

## 📱 REFERÊNCIA RÁPIDA: VALORES COMUNS

### NCM por Categoria
```
Bebidas Alcoólicas: 22021000 (Cerveja)
Refrigerantes: 22021000
Sucos: 20091900 (Suco concentrado)
Água: 22011000 (Água mineral)
Destilados: 22080000 (Bebidas destiladas)
Vinhos: 22042100 (Vinho)
```

### CFOP Comuns
```
5102 = Venda PDV (Consumidor - NFC-e)
5405 = Venda B2B (Empresa - NF-e)
6102 = Compra PDV (Consumidor)
6405 = Compra B2B (Empresa)
```

### CST ICMS Comuns
```
00 = Tributada (ICMS cobrado)
20 = Simples Nacional
40 = Isenta (ICMS não cobrado)
60 = NÃO tributada (importação)
```

### Regime Tributário
```
1 = Simples Nacional
2 = Lucro Real
3 = Lucro Presumido
```

---

## ⚠️ ERROS COMUNS

| Erro | Causa | Solução |
|------|-------|---------|
| "NCM inválido" | NCM do produto está errado | Verificar NCM correto para o produto |
| "CFOP inválido" | CFOP incompatível com tipo de venda | Usar 5102 para PDV (consumidor) |
| "Município inválido" | Código IBGE incorreto | Verificar em https://www.ibge.gov.br/ |
| "Certificado inválido" | Arquivo .p12 não carregado | Fazer upload do certificado em Configurações |
| "Token inválido" | Focus NFe token errado/expirado | Gerar novo token em https://focusnfe.com.br/ |
| "Impostos zerados" | Alíquotas não configuradas | Executar script de alíquotas padrão |

---

## 🚀 PRÓXIMOS PASSOS

### Hoje
- [ ] Executar `01-ADICIONAR_CAMPOS_FISCAIS.sql`
- [ ] Preencher dados empresa em Configurações
- [ ] Encontrar Código IBGE município

### Amanhã
- [ ] Obter Certificado Digital (se não tiver)
- [ ] Gerar Token Focus NFe
- [ ] Carregador certificado em Configurações
- [ ] Testar emissão em Homologação

### Na Semana
- [ ] Validar com contador dados fiscais
- [ ] Treinar operadores PDV
- [ ] Emitir 5-10 testes
- [ ] Migrar para Produção

---

## 📞 SUPORTE

**Focus NFe Help:**
- Site: https://focusnfe.com.br/
- Documentação: https://focusnfe.com.br/api/v2/

**SEFAZ/Receita:**
- Site: https://www.sefaz.fazenda.gov.br/
- Web services: https://nfce.sefaz.rs.gov.br/

**Consultar NCM/CNAE:**
- NCM: https://www.receita.economia.gov.br/
- CNAE: https://concla.ibge.gov.br/

---

**Data:** Fevereiro 3, 2026
**Status:** Pronto após executar script + preencher dados
**Tempo estimado:** 2 horas (incluindo pesquisa de códigos)
