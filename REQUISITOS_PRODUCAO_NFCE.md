# 📋 Requisitos para Emissão de NFC-e em Produção

## ✅ O Que Você Precisa Fazer ANTES de Passar para Produção

### 1. **Configurações na SEFAZ do seu Estado**

#### 🔐 Gerar CSC e ID Token
1. Acesse o portal da SEFAZ do seu estado
2. Entre na área de NFC-e
3. Gere o **CSC** (Código de Segurança do Contribuinte)
4. Gere o **ID Token** (geralmente é um número como "1", "00001", etc.)
5. **GUARDE ESSES CÓDIGOS** - você vai precisar deles!

> ⚠️ **Importante**: Sem CSC e ID Token NÃO é possível emitir NFC-e

### 2. **Habilitar Emissão de NFC-e na SEFAZ**
- Certifique-se de que sua empresa está **habilitada** para emitir NFC-e
- Verifique se a **série** que vai usar está autorizada (geralmente série 1)

### 3. **Configurar no Sistema**

#### No Painel da Focus NFe ou via API:
```javascript
{
  "habilita_nfce": true,
  "csc_nfce_producao": "SEU_CSC_AQUI",
  "id_token_nfce_producao": "1", // ou o número que a SEFAZ gerou
  "serie_nfce_producao": 1
}
```

#### Na tela de Configurações da Empresa:
1. Vá em **Configurações da Empresa**
2. Mude **"Ambiente Focus NFe"** de **"Homologação"** para **"Produção"**
3. Informe o **CSC** e **ID Token** gerados na SEFAZ
4. Salve

### 4. **Certificado Digital (se necessário)**
- Alguns estados exigem certificado digital modelo **A1**
- Importe o certificado no Painel da Focus NFe
- Validade: verifique a data de vencimento

---

## 🎯 O Que Você Já Tem Implementado

### ✅ Emissão de NFC-e
- Emissão síncrona (retorna na mesma requisição)
- Contingência offline automática (se SEFAZ fora do ar)
- Salva dados fiscais no banco (`numero_nfce`, `chave_acesso_nfce`, `protocolo_nfce`)
- Status fiscal atualizado (`EMITIDA_NFCE`)

### ✅ Impressão de DANFE
- Busca pela chave de acesso
- Abre PDF em nova aba
- Funciona para notas do PDV e da tela de vendas

### ✅ Cancelamento de NFC-e
- Prazo: até **30 minutos** após emissão
- Justificativa obrigatória (mínimo 15 caracteres)
- Valida prazo antes de cancelar
- Atualiza status fiscal para `CANCELADA_NFCE`

---

## 📝 Campos Obrigatórios para NFC-e

### Dados Gerais
- `natureza_operacao`: "VENDA AO CONSUMIDOR" (padrão)
- `data_emissao`: Data/hora atual em formato ISO
- `presenca_comprador`: `1` (Presencial) ou `4` (Entrega domicílio)
- `cnpj_emitente`: CNPJ da empresa
- `modalidade_frete`: `9` (Sem frete) - **OBRIGATÓRIO**
- `local_destino`: `1` (Operação interna)

### Dados do Destinatário (Opcional)
- `nome_destinatario`
- `cpf_destinatario` ou `cnpj_destinatario`
- `telefone_destinatario`
- Endereço completo (se informar)

### Itens (Obrigatórios)
- `numero_item`: Sequencial (1, 2, 3...)
- `codigo_ncm`: NCM do produto (8 dígitos)
- `codigo_produto`: Código interno
- `descricao`: Descrição do produto
- `quantidade_comercial`
- `quantidade_tributavel`
- `cfop`: Código fiscal (ex: `5102`)
- `valor_unitario_comercial`
- `valor_unitario_tributavel`
- `valor_bruto`
- `unidade_comercial`: UN, KG, L, etc.
- `unidade_tributavel`
- `icms_origem`: `0` (Nacional)
- `icms_situacao_tributaria`:
  - Simples: `102` (sem crédito)
  - Normal: `00` (tributada), `40` (isenta), `41` (não tributada)

### Formas de Pagamento (Obrigatórias)
```javascript
"formas_pagamento": [
  {
    "forma_pagamento": "01", // 01=Dinheiro, 03=Crédito, 04=Débito
    "valor_pagamento": 100.00
  }
]
```

#### Cartão (se usar 03 ou 04):
- `tipo_integracao`: `1` (TEF) ou `2` (Não integrado)
- `cnpj_credenciadora`: CNPJ da operadora
- `numero_autorizacao`: NSU
- `bandeira_operadora`: `01`=Visa, `02`=Mastercard, etc.

### Totalizadores (Calculados Automaticamente)
- `valor_produtos`
- `valor_desconto`
- `valor_total`
- `icms_base_calculo`
- `icms_valor_total`

---

## ⚠️ Diferenças Homologação vs Produção

### ✅ O Que É IGUAL em Ambos:
- ✅ **Validação de campos obrigatórios** (todos!)
- ✅ **Formato dos dados** (CNPJ, CPF, datas, valores)
- ✅ **Cálculos de impostos** (devem estar corretos)
- ✅ **NCM e CFOP** (devem ser válidos)
- ✅ **CST/CSOSN** (situação tributária correta)
- ✅ **Estrutura do XML** (schema validado)
- ✅ **Regras de negócio** (Simples Nacional, substituição tributária, etc.)

> 🎯 **Importante**: Se a nota for **rejeitada em homologação**, será **rejeitada em produção** também!

### ⚡ O Que É DIFERENTE:

| Item | Homologação | Produção |
|------|-------------|----------|
| **Validade Fiscal** | ❌ Não tem valor legal | ✅ Tem valor legal |
| **Consulta Pública** | ❌ Não aparece no portal | ✅ Aparece no portal nacional |
| **URL** | `https://homologacao.focusnfe.com.br` | `https://api.focusnfe.com.br` |
| **CSC** | CSC de teste (SEFAZ fornece) | CSC real (você gera) |
| **Certificado** | Pode usar vencido em alguns estados* | Deve usar válido** |
| **Numeração** | Independente de produção | Independente de homologação |
| **Destinatário** | Pode usar nome padrão de teste | Deve usar dados reais |

\* Alguns estados não exigem certificado para NFC-e  
\** Se o estado exigir

### 📝 Exemplo de Destinatário em Homologação:
```json
{
  "nome_destinatario": "NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL",
  "cpf_destinatario": "12345678909"
}
```

---

## 🚨 Cuidados ao Passar para Produção

### ❌ NÃO FAÇA:
- ❌ Não teste em produção "só pra ver se funciona"
- ❌ Não cancele notas desnecessariamente (limite de 30 min)
- ❌ Não emita notas duplicadas
- ❌ Não use dados fictícios de clientes

### ✅ FAÇA:
- ✅ Teste TUDO em homologação primeiro
- ✅ Tenha certeza de que está tudo configurado
- ✅ Verifique os dados antes de emitir
- ✅ Guarde os XMLs por pelo menos 5 anos
- ✅ Monitore os backups automáticos da Focus NFe

---

## 🔄 Fluxo Completo em Produção

```
1. Cliente finaliza compra no PDV
   ↓
2. Sistema valida dados
   ↓
3. Envia para Focus NFe
   ↓
4. Focus NFe envia para SEFAZ
   ↓
5. SEFAZ autoriza ou rejeita
   ↓
6. Se autorizada:
   - Salva dados fiscais (chave, número, protocolo)
   - Gera DANFE
   - Oferece para imprimir
   ↓
7. Se SEFAZ offline:
   - Emite em contingência offline
   - Tenta transmitir depois automaticamente
```

---

## 📞 Suporte

- **Focus NFe**: suporte@focusnfe.com.br
- **Documentação**: https://focusnfe.com.br/doc/#nfce

---

## ✅ Checklist Final

Antes de passar para produção, verifique:

- [ ] CSC e ID Token gerados na SEFAZ
- [ ] CSC e ID Token configurados no sistema
- [ ] Empresa habilitada para NFC-e na SEFAZ
- [ ] Certificado digital importado (se necessário)
- [ ] Ambiente alterado para "Produção"
- [ ] Série configurada corretamente
- [ ] Todos os testes em homologação OK
- [ ] NCM dos produtos corretos
- [ ] CFOP configurado (geralmente 5102)
- [ ] Formas de pagamento implementadas
- [ ] Contingência offline habilitada (opcional)

---

**Tudo pronto?** Mude o ambiente para **Produção** e boa sorte! 🚀
