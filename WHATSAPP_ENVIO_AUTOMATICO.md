# 📱 Configuração de Envio Automático de PDF via WhatsApp

## Visão Geral

Este sistema permite enviar PDFs de vendas automaticamente pelo WhatsApp sem precisar abrir o aplicativo manualmente. O PDF é enviado diretamente para o número do cliente cadastrado.

## ⚙️ Pré-requisitos

Você precisa ter uma **API do WhatsApp** configurada. As opções recomendadas são:

### 1️⃣ **Evolution API** (Recomendado - Gratuito)

✅ **Vantagens:**
- Gratuito e open-source
- Fácil de instalar
- Não precisa pagar mensalidade
- Auto-hospedado (você controla)

📖 **Como instalar:**

1. Acesse: https://github.com/EvolutionAPI/evolution-api
2. Siga as instruções de instalação (Docker recomendado)
3. Após instalado, você terá:
   - URL da API: `http://seu-servidor:8080` (ou domínio)
   - API Key: gerada na instalação
   - Instance ID: nome da instância que você criar

### 2️⃣ **Twilio** (Oficial - Pago)

✅ **Vantagens:**
- API oficial do WhatsApp Business
- Mais estável
- Suporte profissional

📖 **Como configurar:**

1. Crie conta em: https://www.twilio.com/whatsapp
2. Configure número do WhatsApp Business
3. Obtenha as credenciais:
   - Account SID
   - Auth Token

## 🔧 Configuração no Sistema

### Passo 1: Execute o SQL

Execute este SQL no Supabase SQL Editor:

```sql
-- Arquivo: EXECUTAR_adicionar-whatsapp-api.sql
```

### Passo 2: Configure na Empresa

1. Acesse **Configurações da Empresa**
2. Na seção **🔌 Integração WhatsApp API**, preencha:

#### Para Evolution API:
- **Provedor da API**: `Evolution API`
- **Número de Origem**: `5511999999999` (seu número com DDI + DDD)
- **URL da API**: `http://seu-servidor:8080` ou `https://seu-dominio.com`
- **API Key / Token**: Cole o token da Evolution API
- **ID da Instância**: Nome da instância (ex: `minha-empresa`)

#### Para Twilio:
- **Provedor da API**: `Twilio`
- **Número de Origem**: `5511999999999`
- **URL da API**: `https://api.twilio.com/2010-04-01`
- **API Key / Token**: Seu Account SID:Auth Token

3. Clique em **💾 Salvar Configurações**

### Passo 3: Cadastre o WhatsApp do Cliente

1. Vá em **Clientes**
2. Edite o cliente
3. Preencha o campo **WhatsApp** no formato: `5511999999999`
   - ⚠️ Incluir o DDI (55 para Brasil)
   - Sem espaços, parênteses ou traços

## 📤 Como Usar

### Enviando PDF da Venda

1. Abra a **Venda** (deve estar APROVADA ou FINALIZADA)
2. Clique no botão **📱 Enviar WhatsApp**
3. Confirme o envio
4. ✅ Pronto! O PDF será enviado automaticamente

### Mensagem Enviada

O sistema envia automaticamente:
```
Olá! Segue o pedido de venda #VENDA-001.

Total: R$ 150,00

Obrigado pela preferência!
```

Com o PDF em anexo: `venda_VENDA-001.pdf`

## 🐛 Solução de Problemas

### "API do WhatsApp não configurada"
- Verifique se preencheu todos os campos em Configurações da Empresa
- Execute o SQL `EXECUTAR_adicionar-whatsapp-api.sql`

### "Cliente não possui WhatsApp cadastrado"
- Edite o cliente e adicione o WhatsApp
- Formato correto: `5511999999999` (com DDI)

### "Erro na API"
- **Evolution API**: Verifique se o servidor está rodando
- **Evolution API**: Confirme se a instância está conectada
- **Twilio**: Verifique suas credenciais e saldo

### "Número inválido"
- Certifique-se que o WhatsApp do cliente está no formato: `DDI + DDD + Número`
- Exemplo: `5511999999999` (Brasil)
- Sem espaços, parênteses ou caracteres especiais

## 📋 Checklist de Configuração

- [ ] SQL executado no Supabase
- [ ] API do WhatsApp instalada/configurada
- [ ] Campos preenchidos em Configurações da Empresa
- [ ] WhatsApp do cliente cadastrado corretamente
- [ ] Teste enviando um PDF de venda

## 💡 Dicas

1. **Evolution API**: Recomendamos hospedar em um servidor sempre ligado (VPS)
2. **Backup do QR Code**: Faça backup da sessão da Evolution API
3. **Teste primeiro**: Faça um teste com seu próprio número antes de enviar para clientes
4. **Whats App Business**: Use número Business para melhor experiência

## 🔐 Segurança

- A API Key fica armazenada de forma segura no banco de dados
- Apenas ADMIN pode configurar a API
- As chamadas são autenticadas

## 📞 Suporte

Se tiver problemas:
- Evolution API: https://doc.evolution-api.com/
- Twilio: https://support.twilio.com/

---

✨ **Pronto!** Agora você pode enviar PDFs automaticamente pelo WhatsApp!
