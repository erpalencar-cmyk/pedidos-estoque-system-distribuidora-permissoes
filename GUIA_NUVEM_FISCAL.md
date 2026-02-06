# 📘 Guia de Integração Nuvem Fiscal

## Visão Geral

Este guia documenta a integração completa da **Nuvem Fiscal API** no sistema de vendas e estoque, oferecendo uma alternativa econômica à Focus NFe com funcionalidades adicionais de consulta de CEP e CNPJ.

### Vantagens da Nuvem Fiscal

| Recurso | Focus NFe | Nuvem Fiscal |
|---------|-----------|--------------|
| **Custo Mensal** | ~R$ 150/mês | **GRATUITO** (até limites) |
| **NFC-e/mês** | Ilimitado | 1.000 documentos |
| **Consultas CEP** | ❌ Não incluído | ✅ 100.000/mês |
| **Consultas CNPJ** | ❌ Não incluído | ✅ 50.000/mês |
| **Autenticação** | Token fixo | OAuth2 Client Credentials |

---

## 🚀 Instalação

### 1. Executar Migração do Banco de Dados

Antes de usar a Nuvem Fiscal, execute a migração SQL para adicionar os campos necessários:

```sql
-- database/migrations/add-nuvem-fiscal-config.sql
-- Execute este script no Supabase SQL Editor

ALTER TABLE empresa_config
ADD COLUMN IF NOT EXISTS nuvemfiscal_client_id TEXT,
ADD COLUMN IF NOT EXISTS nuvemfiscal_client_secret TEXT,
ADD COLUMN IF NOT EXISTS nuvemfiscal_access_token TEXT,
ADD COLUMN IF NOT EXISTS nuvemfiscal_token_expiry TIMESTAMP,
ADD COLUMN IF NOT EXISTS api_fiscal_provider VARCHAR(20) DEFAULT 'focus_nfe' 
  CHECK (api_fiscal_provider IN ('focus_nfe', 'nuvem_fiscal'));

COMMENT ON COLUMN empresa_config.nuvemfiscal_client_id IS 'Client ID da API Nuvem Fiscal (OAuth2)';
COMMENT ON COLUMN empresa_config.nuvemfiscal_client_secret IS 'Client Secret da API Nuvem Fiscal (OAuth2)';
COMMENT ON COLUMN empresa_config.nuvemfiscal_access_token IS 'Access Token OAuth2 em cache';
COMMENT ON COLUMN empresa_config.nuvemfiscal_token_expiry IS 'Data/hora de expiração do access token';
COMMENT ON COLUMN empresa_config.api_fiscal_provider IS 'Provedor de API fiscal a ser utilizado: focus_nfe ou nuvem_fiscal';

CREATE INDEX IF NOT EXISTS idx_empresa_config_api_provider ON empresa_config(api_fiscal_provider);
```

**Passos:**
1. Acesse o Supabase Dashboard → SQL Editor
2. Cole o script acima
3. Clique em "Run" para executar
4. Verifique se não há erros

### 2. Registrar-se na Nuvem Fiscal e Obter Credenciais OAuth2

A Nuvem Fiscal usa **OAuth2 Client Credentials** para autenticação.

**Passo 1: Criar Conta**
1. Acesse: https://nuvemfiscal.com.br
2. Crie sua conta gratuitamente
3. Faça login no console

**Passo 2: Criar Credenciais de API**
1. Acesse o **Console Nuvem Fiscal**: https://console.nuvemfiscal.com.br
2. Vá em **Credenciais de API**
3. Clique em **"Criar credencial"**
4. Escolha o tipo:
   - **Sandbox**: Para testes (use primeiro)
   - **Produção**: Para emissão real de notas
5. Clique em **"Confirmar"**
6. Você verá uma tela com:
   - **Client ID**: Ex: `OSYlsKpf3rKHMsqQKw8z`
   - **Client Secret**: Código secreto (mostrado apenas uma vez!)

⚠️ **IMPORTANTE**: 
- O **Client Secret** só é mostrado UMA VEZ
- Anote ou baixe o arquivo CSV imediatamente
- Se perder o Client Secret, terá que criar novas credenciais

### 3. Configurar Credenciais no Sistema

1. Acesse **Configurações da Empresa** no menu lateral
2. Vá na aba **NF-e / NFC-e**
3. No campo **"Provedor de API Fiscal"**, selecione **Nuvem Fiscal**
4. Preencha as credenciais OAuth2:
   - **Client ID**: Cole o identificador público (ex: `OSYlsKpf3rKHMsqQKw8z`)
   - **Client Secret**: Cole o código secreto (⚠️ mantenha em segredo!)
5. Clique em **"Testar Conexão Nuvem Fiscal"** para validar
6. Se o teste passar com sucesso (✅), clique em **"Salvar Configurações"**

**Como funciona a autenticação:**
- O sistema usa suas credenciais OAuth2 para obter um **Access Token**
- O Access Token expira após 30 dias (2.592.000 segundos)
- O sistema renova automaticamente quando necessário
- Você não precisa se preocupar com renovação manual

---

## 📋 Configuração de Empresa para NFC-e

A Nuvem Fiscal exige configuração adicional por empresa para emitir NFC-e:

### Configurar CSC (Código de Segurança do Contribuinte)

O CSC é obrigatório para emissão de NFC-e e é obtido no portal da SEFAZ do seu estado.

**Via Sistema (Automático):**
1. Na aba **NF-e / NFC-e**, preencha:
   - **CSC ID**: Geralmente `000001`
   - **CSC Token**: Código fornecido pela SEFAZ
2. O sistema irá configurar automaticamente via API

**Via API (Manual - se necessário):**
```javascript
// Exemplo: Configurar empresa via JavaScript
const resultado = await NuvemFiscal.configurarEmpresa('00000000000191', {
    crt: 1, // Código de Regime Tributário (1=Simples Nacional, 3=Normal)
    id_csc: '000001',
    csc: 'ABC123...seu código CSC'
});
```

---

## 💡 Funcionalidades

### 1. Emissão de NFC-e

O sistema detecta automaticamente qual provedor usar baseado na configuração.

**Fluxo de Emissão:**
1. Cliente finaliza venda no PDV
2. Sistema verifica o `api_fiscal_provider` configurado
3. Se `nuvem_fiscal`:
   - Monta payload no formato da Nuvem Fiscal
   - Envia via `POST /nfce`
   - Aguarda processamento (polling se status "pendente")
   - Atualiza venda com chave, número e protocolo
4. Se `focus_nfe`:
   - Usa o fluxo original via Edge Function

**Código (já implementado em fiscal.js):**
```javascript
// O sistema faz isso automaticamente
const resultado = await FiscalSystem.emitirNFCe(vendaId);

// Resultado:
// {
//   sucesso: true,
//   numero: '000000001',
//   chave: '35240511222333000140650010000000011234567890',
//   protocolo: '135240000000001',
//   provider: 'nuvem_fiscal'
// }
```

### 2. Consulta de CEP (Auto-preenchimento)

A consulta de CEP preenche automaticamente os campos de endereço em qualquer formulário.

**Uso Automático:**
- Os campos de CEP já têm um botão de busca (🔍) automaticamente
- Ao digitar 8 dígitos e sair do campo, busca automaticamente (se logradouro vazio)
- Pressionar Enter no campo CEP também aciona a busca

**Campos Preenchidos:**
- Logradouro (Rua, Avenida, etc)
- Bairro
- Cidade
- UF (Estado)
- Código IBGE

**Uso Manual (JavaScript):**
```javascript
// Buscar CEP e preencher campos
await CEPService.preencherEndereco('01310-100', 'cliente-');
// Preenche: cliente-logradouro, cliente-bairro, cliente-cidade, cliente-uf

// Apenas consultar sem preencher
const endereco = await CEPService.consultar('01310-100');
console.log(endereco);
// {
//   cep: '01310-100',
//   logradouro: 'Avenida Paulista',
//   bairro: 'Bela Vista',
//   cidade: 'São Paulo',
//   uf: 'SP',
//   codigo_ibge: '3550308'
// }
```

**Onde está disponível:**
- ✅ Configurações da Empresa
- ✅ Cadastro de Clientes
- ✅ Cadastro de Fornecedores
- ✅ Modals de cadastro rápido

### 3. Consulta de CNPJ (Auto-preenchimento)

A consulta de CNPJ busca dados completos da Receita Federal e preenche todos os campos.

**Uso Automático:**
- Campos de CNPJ também têm botão de busca (🔍)
- Pressionar Enter aciona a busca
- Validação automática de dígitos verificadores

**Campos Preenchidos:**
- Razão Social
- Nome Fantasia
- Endereço completo (logradouro, número, bairro, CEP, cidade, UF)
- Telefone e Email (se disponível)
- CNAE Principal
- Natureza Jurídica
- Porte da Empresa
- Capital Social
- Data de Abertura
- Situação Cadastral
- Indicadores: Simples Nacional, MEI

**Uso Manual (JavaScript):**
```javascript
// Buscar CNPJ e preencher campos
await CNPJService.preencherDados('11222333000140', 'empresa-');

// Apenas consultar
const empresa = await CNPJService.consultar('11222333000140');
console.log(empresa);
// {
//   cnpj: '11.222.333/0001-40',
//   razao_social: 'EMPRESA EXEMPLO LTDA',
//   nome_fantasia: 'Empresa Exemplo',
//   situacao_cadastral: 'ATIVA',
//   logradouro: 'Rua das Flores',
//   numero: '123',
//   bairro: 'Centro',
//   cidade: 'São Paulo',
//   uf: 'SP',
//   cep: '01310-100',
//   telefone: '(11) 98765-4321',
//   email: 'contato@empresa.com.br',
//   cnae_principal: '4712100',
//   descricao_cnae: 'Comércio varejista de mercadorias em geral',
//   simples_nacional: true,
//   mei: false,
//   ...
// }
```

**Onde está disponível:**
- ✅ Configurações da Empresa
- ✅ Cadastro de Clientes (empresas)
- ✅ Cadastro de Fornecedores
- ✅ Modals de cadastro rápido

---

## 🔄 Migração de Focus NFe para Nuvem Fiscal

### Checklist de Migração

- [ ] Executar migração SQL no banco de dados
- [ ] Registrar conta na Nuvem Fiscal
- [ ] Obter token de API
- [ ] Configurar token no sistema
- [ ] Testar conexão (botão "Testar Conexão")
- [ ] Configurar CSC da empresa
- [ ] Emitir NFC-e de teste em homologação
- [ ] Validar XML e DANFCE gerados
- [ ] Configurar ambiente de produção
- [ ] Emitir primeira nota em produção
- [ ] Validar consulta no portal da SEFAZ

### Manter Ambas APIs

O sistema suporta **ambas as APIs simultaneamente**. Você pode:

1. **Testar Nuvem Fiscal em homologação** enquanto usa Focus NFe em produção
2. **Alternar entre provedores** a qualquer momento nas configurações
3. **Usar Nuvem Fiscal para CEP/CNPJ** e Focus NFe para notas (se preferir)

**Para alternar:**
1. Acesse Configurações da Empresa → NF-e / NFC-e
2. Mude o "Provedor de API Fiscal"
3. Salve as configurações
4. As próximas notas usarão o novo provedor

---

## 🛠️ Troubleshooting

### Erro: "Token da Nuvem Fiscal não configurado"

**Solução:**
1. Verifique se executou a migração SQL
2. Acesse Configurações da Empresa
3. Cole o token no campo correto
4. Salve as configurações
5. Recarregue a página

### Erro: "CNPJ não encontrado" ou "CEP não encontrado"

**Possíveis Causas:**
- CNPJ/CEP inválido (verificar dígitos)
- CNPJ não existe na Receita Federal
- Quota de consultas esgotada (50.000 CNPJ, 100.000 CEP por mês)
- Token inválido ou expirado

**Solução:**
1. Valide o CNPJ/CEP digitado
2. Verifique quota no dashboard da Nuvem Fiscal
3. Teste a conexão (botão "Testar Conexão")
4. Se necessário, gere novo token

### Erro: "NFC-e rejeitada: CSC inválido"

**Solução:**
1. Verifique o CSC ID e Token na aba NF-e/NFC-e
2. Confirme os dados no portal da SEFAZ
3. Execute a configuração novamente
4. Teste em homologação primeiro

### Erro: "Status pendente após múltiplas tentativas"

**Causa:** A SEFAZ está demorando para processar (pode acontecer em horários de pico)

**Solução:**
1. Aguarde alguns minutos
2. Consulte manualmente a nota:
```javascript
const resultado = await NuvemFiscal.consultarNFCe('id_da_nota');
console.log(resultado.status);
```
3. Se persistir, verifique status da SEFAZ no dashboard Nuvem Fiscal

---

## 📊 Monitoramento de Quotas

### Verificar Consumo

Acesse o dashboard da Nuvem Fiscal para monitorar:
- **DFE Eventos:** 1.000 unidades/mês (cada NFC-e = 1 unidade)
- **CEP Consultas:** 100.000 unidades/mês
- **CNPJ Consultas:** 50.000 unidades/mês

### Planos Pagos

Se exceder os limites gratuitos, a Nuvem Fiscal oferece planos pagos:
- **Starter:** R$ 29/mês - 10.000 documentos
- **Professional:** R$ 99/mês - 50.000 documentos
- **Enterprise:** Sob consulta - Ilimitado

Ainda assim mais barato que Focus NFe para maioria dos casos.

---

## 🔐 Segurança

### Armazenamento de Tokens

- Tokens são armazenados criptografados no banco de dados Supabase
- Transmissão via HTTPS (TLS 1.3)
- Nunca expor tokens em logs ou console (produção)

### Boas Práticas

1. **Rotacionar tokens periodicamente** (a cada 90 dias)
2. **Usar ambiente de homologação** para testes
3. **Monitorar logs de emissão** para detectar anomalias
4. **Revogar tokens antigos** ao gerar novos

---

## 📞 Suporte

### Nuvem Fiscal
- Site: https://nuvemfiscal.com.br
- Documentação: https://dev.nuvemfiscal.com.br/docs/api/
- Email: suporte@nuvemfiscal.com.br

### Sistema
- Para problemas com a integração, verifique:
  - Console do navegador (F12) para erros JavaScript
  - Logs do Supabase para erros de banco de dados
  - Network tab para erros de API

---

## 📝 Changelog

### v1.0.0 - 2024
- ✅ Integração completa com Nuvem Fiscal API
- ✅ Emissão de NFC-e via Nuvem Fiscal
- ✅ Consulta automática de CEP com auto-preenchimento
- ✅ Consulta automática de CNPJ com auto-preenchimento
- ✅ Suporte dual para Focus NFe e Nuvem Fiscal
- ✅ UI de configuração de provedor
- ✅ Migração de banco de dados
- ✅ Tratamento de erros e retentativas
- ✅ Polling para processamento assíncrono

---

## 🎯 Próximos Passos (Roadmap)

- [ ] Suporte para NF-e (Nota Fiscal Eletrônica)
- [ ] Suporte para CT-e (Conhecimento de Transporte)
- [ ] Inutilização de numeração
- [ ] Carta de Correção Eletrônica (CC-e)
- [ ] Consulta de status SEFAZ automática
- [ ] Relatórios de consumo de quota
- [ ] Webhook para eventos assíncronos
- [ ] Cache de consultas CEP/CNPJ

---

## 💻 Exemplos de Código

### Emitir NFC-e Programaticamente

```javascript
// Exemplo: Emitir NFC-e para uma venda específica
async function emitirNota(vendaId) {
    try {
        const resultado = await FiscalSystem.emitirNFCe(vendaId);
        
        if (resultado.sucesso) {
            console.log('✅ NFC-e emitida com sucesso!');
            console.log('Número:', resultado.numero);
            console.log('Chave:', resultado.chave);
            console.log('Provedor:', resultado.provider);
        }
    } catch (erro) {
        console.error('❌ Erro ao emitir NFC-e:', erro.message);
    }
}
```

### Consultar e Baixar PDF

```javascript
// Consultar nota existente
const nota = await NuvemFiscal.consultarNFCe('id_da_nota');
console.log('Status:', nota.status);

// Baixar PDF
const pdf = await NuvemFiscal.baixarPDF('id_da_nota');
const url = URL.createObjectURL(pdf);
window.open(url); // Abrir PDF em nova aba

// Baixar XML
const xml = await NuvemFiscal.baixarXML('id_da_nota');
```

### Adicionar Botão de CEP em Formulário Customizado

```html
<!-- HTML -->
<div class="relative">
    <label>CEP</label>
    <input type="text" id="meu-cep" maxlength="9" />
</div>

<script>
// JavaScript
CEPService.adicionarBotaoConsulta('meu-cep', 'meu-');
// Campos esperados: meu-logradouro, meu-bairro, meu-cidade, meu-uf
</script>
```

---

**✨ Pronto! Agora você tem uma integração completa e econômica para emissão de notas fiscais e consultas de dados.**
