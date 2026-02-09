# 🔧 Guia: Fix - Sincronização de NF-e via API de Distribuição

## ❌ Problema Identificado

O sistema estava sincronizando apenas **NFCe** ao tentar sincronizar NF-e, porque:

1. **Endpoints antigos usavam:**
   - `GET /nf-e` - Retorna NF-e genéricas (pode ser inconsistente)
   - `GET /nfce` - Retorna especificamente NFC-e

2. **API Nuvem Fiscal tem dois conceitos:**
   - Notas recebidas direto (`/nf-e`, `/nfce`) - Nem sempre retorna todas as notas
   - **Distribuição SEFAZ** (`/distribuicao-nf-e`) - Oficial, retorna documentos distribuídos

## ✅ Solução Implementada

### 1. Novos Métodos no `nuvem-fiscal.js`

Adicionados 3 novos métodos à classe `NuvemFiscalService`:

#### `buscarDistribuicaoNFe(cpfCnpj, ambiente, top, dataInicio, dataFim)`
```javascript
// Busca documentos distribuídos via API de Distribuição do SEFAZ
const resultado = await NuvemFiscal.buscarDistribuicaoNFe(
    cnpj,
    'homologacao',
    100,
    '2026-01-01',
    '2026-02-09'
);
// Retorna: { data: [ { chave_acesso, numero, emitente, ... } ] }
```

#### `baixarXMLDistribuicao(chaveAcesso)`
```javascript
// Download via GET com chave de acesso
const xmlBlob = await NuvemFiscal.baixarXMLDistribuicao('1234567890123456789012345678901234567890123456');
```

#### `baixarXMLDistribuicaoPost(chaveAcesso)`
```javascript
// Download via POST (alternativa se GET não funcionar)
const xmlBlob = await NuvemFiscal.baixarXMLDistribuicaoPost('1234567890123456789012345678901234567890123456');
```

### 2. Atualização do `sync-notas-recebidas.js`

#### Busca de NF-e:
- **Agora tenta primeiro:** `NuvemFiscal.buscarDistribuicaoNFe()` ✨ (novo)
- **Se falhar, usa fallback:** `NuvemFiscal.listarNFeRecebidas()` (original)
- **NFCe continua:** `NuvemFiscal.listarNFCeRecebidas()` (sem mudanças)

#### Download de XML:
- Para **NF-e**: Tenta `baixarXMLDistribuicao()` → fallback para `baixarXMLNotaRecebida()`
- Para **NFCe**: Continua usando `baixarXMLNotaRecebida()`

### 3. Fluxo de Sincronização (Novo)

```
[Iniciar Sincronização]
    ↓
├─ NF-e?
│   ├─ Tentar: buscarDistribuicaoNFe() ✨ (API de Distribuição)
│   │   ├─ ✅ Sucesso → usar dados
│   │   └─ ❌ Erro → Fallback para listarNFeRecebidas()
│   └─ Downloads com baixarXMLDistribuicao()
│
├─ NFCe?
│   ├─ Usar: listarNFCeRecebidas() (sem mudanças)
│   └─ Downloads com baixarXMLNotaRecebida()
│
└─ [Importar como Pedidos de Compra]
```

## 📋 Referência da API

**Documentação Oficial:**
- https://dev.nuvemfiscal.com.br/docs/api/#tag/Distribuicao-NF-e

**Endpoints Usados:**

| Endpoint | Método | Descrição |
|----------|--------|-----------|
| `/distribuicao-nf-e` | GET | Buscar documentos distribuídos |
| `/distribuicao-nf-e/download` | GET/POST | Baixar XML da distribuição |
| `/nf-e` | GET | Buscar NF-e (legado, fallback) |
| `/nfce` | GET | Buscar NFC-e |

**Parâmetros da API de Distribuição:**

```
GET /distribuicao-nf-e?
    cpf_cnpj=00000000000191       # CNPJ da empresa (destinatária)
    &ambiente=homologacao         # Ambiente
    &$top=100                     # Limite de resultados
    &$orderby=data_emissao desc   # Ordenação
    &$filter=...                  # Filtros de data
```

## 🧪 Como Testar

### Via Console do Navegador:

```javascript
// 1. Testar busca sem filtros
const resultado = await NuvemFiscal.buscarDistribuicaoNFe(
    '00.000.000/0001-91',  // Seu CNPJ
    'homologacao',
    10
);
console.log('Documentos encontrados:', resultado.data?.length);

// 2. Testar busca com filtro de data
const resultado = await NuvemFiscal.buscarDistribuicaoNFe(
    '00.000.000/0001-91',
    'homologacao',
    100,
    '2026-01-01',  // Data início
    '2026-02-09'   // Data fim
);
console.log('Documentos no período:', resultado.data);

// 3. Testar download de XML
const xml = await NuvemFiscal.baixarXMLDistribuicao('1234567890123456789012345678901234567890123456');
console.log('XML baixado com sucesso');
```

### Via Interface:

1. Acesse **Pedidos de Compra** → **Sincronizar Notas Recebidas**
2. Selecione:
   - ✅ NF-e
   - ✅ NFC-e (opcional)
3. Defina período (opcional)
4. Clique em **Sincronizar**
5. Verifique console do navegador (F12) para logging detalhado

## 📊 Logs Esperados

### Sucesso com API de Distribuição:

```
📋 [NuvemFiscal] Buscando documentos (Distribuição NF-e): /distribuicao-nf-e?...
📋 [NuvemFiscal] Documentos distribuídos encontrados: 5
✅ [SincronizacaoNotasRecebidas] 5 NF-e encontradas via distribuição
   📥 Tentando download via API de Distribuição...
   📥 [NuvemFiscal] Baixando XML via Distribuição: 1234567890123456789...
   ✅ XML baixado com sucesso
```

### Fallback para método original:

```
⚠️ [SincronizacaoNotasRecebidas] Erro ao listar NF-e via distribuição: ...
⚠️ Tentando método alternativo (GET /nf-e)...
✅ [SincronizacaoNotasRecebidas] 3 NF-e encontradas (método alternativo)
```

## 🔍 Troubleshooting

### "Documentos distribuídos encontrados: 0"

**Possíveis causas:**
1. Nenhuma NF-e foi recebida nesse período
2. CNPJ está incorreto
3. Data do filtro não contém notas
4. Token OAuth2 expirado ou sem permissões

**Soluções:**
- Verifique CNPJ em Configurações da Empresa
- Verifique se há NF-e recebidas no portal SEFAZ
- Estenda o período de datas
- Regenere credenciais OAuth2

### "Erro ao buscar documentos distribuídos"

**Possíveis causas:**
1. Credenciais OAuth2 inválidas/expiradas
2. Escopos OAuth insuficientes
3. Conexão com API

**Soluções:**
- Teste conexão em Configurações → Testar Conexão Nuvem Fiscal
- Regenere token em dashboard Nuvem Fiscal
- Verifique internet/firewall

### "Download via distribuição falhou"

O sistema automaticamente faz fallback para o método original. Verificar:
1. Chave de acesso está correta (44 dígitos)
2. Nota existe no SEFAZ
3. Token OAuth2 válido

## 🚀 Próximos Passos (Opcional)

Para ativa **completamente** a API de Distribuição sem fallback:

1. Edite [js/services/sync-notas-recebidas.js](js/services/sync-notas-recebidas.js#L82)
2. Remova o bloco **try/catch de fallback**
3. Use apenas `buscarDistribuicaoNFe()`

```javascript
// Remover este bloco para usar APENAS a API de Distribuição:
try {
    const nfes = await NuvemFiscal.buscarDistribuicaoNFe(...)
    // ... processar
} catch (erro) {
    // Remove este try/catch para erro imediato
    try {
        const nfes = await NuvemFiscal.listarNFeRecebidas(...)  // ← REMOVER FALLBACK
        // ...
    }
}
```

## 📚 Arquivos Modificados

| Arquivo | Mudança |
|---------|---------|
| [js/services/nuvem-fiscal.js](js/services/nuvem-fiscal.js#L1522) | +3 novos métodos |
| [js/services/sync-notas-recebidas.js](js/services/sync-notas-recebidas.js#L82) | Atualizado fluxo de busca |
| [js/services/sync-notas-recebidas.js](js/services/sync-notas-recebidas.js#L188) | Atualizado fluxo de download |

---

**Data da implementação:** 2026-02-09  
**Versão:** 1.0  
**Status:** ✅ Pronto para uso
