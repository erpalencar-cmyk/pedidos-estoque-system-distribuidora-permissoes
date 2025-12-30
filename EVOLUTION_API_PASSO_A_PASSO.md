# 🚀 Guia Completo: Instalando Evolution API do Zero

## 📋 O que é Evolution API?

Evolution API é um servidor que conecta seu sistema ao WhatsApp. Funciona assim:

```
Seu Sistema → Evolution API → WhatsApp do Cliente
```

É **gratuito**, **open-source** e você instala no seu próprio servidor.

---

## 🎯 Opções de Instalação

### Opção 1: Usando Serviço Pronto (Mais Fácil - Recomendado) 💰

Se você não quer instalar nada, pode usar um serviço que já hospeda a API do WhatsApp pronta:

**Serviços recomendados:**

1. **Evolution API Cloud** - Serviços que hospedam Evolution para você:
   - Pesquise no Google: "Evolution API hospedagem Brasil"
   - Preço: R$ 30-80/mês
   - Já vem configurado, só usar

2. **WAHA (WhatsApp HTTP API)** - https://waha.devlike.pro
   - **IMPORTANTE**: WAHA é uma API diferente da Evolution
   - Também é open-source e gratuito
   - Precisa instalar no seu servidor (VPS)
   - **Não funciona direto no nosso sistema** (precisa adaptar código)
   
3. **Z-API** - https://z-api.io (Brasileiro)
   - Serviço pago brasileiro
   - Muito fácil de usar
   - R$ 50-150/mês
   - Suporte em português

4. **Baileys Cloud** - Procure "Baileys hospedagem"
   - Baseado em Baileys
   - R$ 40-100/mês

**💡 Recomendação:** Use Evolution API hospedada ou Z-API. São mais compatíveis com nosso sistema.

✅ Vantagem: Já vem tudo pronto, é só cadastrar e usar  
❌ Desvantagem: Paga mensalidade

---

### Opção 2: Instalar no Seu Computador (Para Testes) 💻

**Pré-requisitos:**
- Windows 10/11
- Docker Desktop instalado

#### Passo 1: Instalar Docker Desktop

1. Baixe em: https://www.docker.com/products/docker-desktop/
2. Instale normalmente (Next, Next, Finish)
3. Reinicie o computador
4. Abra o Docker Desktop e aguarde iniciar

#### Passo 2: Baixar Evolution API

1. Abra o **PowerShell** como Administrador
2. Copie e cole este comando:

```powershell
docker run -d `
  --name evolution-api `
  -p 8080:8080 `
  -e AUTHENTICATION_API_KEY="minha-chave-secreta-123" `
  -e INSTANCE_NAME="minha-empresa" `
  atendai/evolution-api:latest
```

3. Aguarde o download (pode demorar alguns minutos)
4. Pronto! A API está rodando em: `http://localhost:8080`

#### Passo 3: Conectar WhatsApp

1. Abra o navegador em: `http://localhost:8080`
2. Você verá uma página da Evolution API
3. Acesse: `http://localhost:8080/instance/connect/minha-empresa`
4. Aparecerá um **QR Code**
5. Abra seu WhatsApp no celular → **Aparelhos conectados** → **Conectar um aparelho**
6. Escaneie o QR Code
7. ✅ Pronto! WhatsApp conectado!

#### Passo 4: Configurar no Sistema

No seu sistema, em **Configurações da Empresa**, preencha:

- **Provedor**: `Evolution API`
- **URL da API**: `http://localhost:8080`
- **API Key**: `minha-chave-secreta-123`
- **ID da Instância**: `minha-empresa`
- **Número de Origem**: Seu WhatsApp (ex: `5511999999999`)

⚠️ **ATENÇÃO**: Isso funciona apenas enquanto seu computador estiver ligado!

---

### Opção 3: Instalar em Servidor VPS (Produção) 🌐

**Para usar 24/7, você precisa de um servidor sempre ligado.**

#### O que você precisa:

1. **VPS** (Servidor Virtual)
   - Recomendados: Contabo, DigitalOcean, AWS
   - Mínimo: 1GB RAM, 1 CPU
   - Sistema: Ubuntu 22.04
   - Custo: R$ 20-50/mês

2. **Domínio** (opcional, mas recomendado)
   - Exemplo: `api.minhaempresa.com`
   - Para ter HTTPS (seguro)

#### Passo 1: Contratar VPS

**Exemplo com Contabo (mais barato):**

1. Acesse: https://contabo.com
2. Escolha: **Cloud VPS S** (€4,50/mês ≈ R$ 25)
3. Selecione:
   - Região: **Europa** (Frankfurt)
   - Sistema: **Ubuntu 22.04**
   - Opções adicionais: Nenhuma
4. Finalize a compra
5. Você receberá por email:
   - IP do servidor (ex: `123.45.67.89`)
   - Usuário: `root`
   - Senha: `sua-senha`

#### Passo 2: Conectar no Servidor

**No Windows:**

1. Baixe o **PuTTY**: https://www.putty.org/
2. Abra o PuTTY
3. Em "Host Name": cole o IP do servidor
4. Clique em "Open"
5. Login: `root`
6. Senha: (cole a senha do email)

#### Passo 3: Instalar Docker no Servidor

Cole estes comandos (um de cada vez):

```bash
# Atualizar sistema
apt update && apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com | bash

# Verificar se instalou
docker --version
```

Deve aparecer algo como: `Docker version 24.0.7`

#### Passo 4: Instalar Evolution API

```bash
# Criar diretório
mkdir /opt/evolution-api
cd /opt/evolution-api

# Criar arquivo de configuração
nano docker-compose.yml
```

Cole este conteúdo (use Shift+Insert para colar no PuTTY):

```yaml
version: '3'

services:
  evolution-api:
    image: atendai/evolution-api:latest
    container_name: evolution-api
    restart: always
    ports:
      - "8080:8080"
    environment:
      # MUDE ESTA CHAVE PARA UMA SUA!
      - AUTHENTICATION_API_KEY=SUA_CHAVE_SECRETA_AQUI_123456
      - INSTANCE_NAME=minha-empresa
    volumes:
      - ./evolution_instances:/evolution/instances
      - ./evolution_store:/evolution/store
```

Salve com: `CTRL+X` → `Y` → `ENTER`

#### Passo 5: Iniciar Evolution API

```bash
# Instalar docker-compose
apt install docker-compose -y

# Iniciar Evolution
docker-compose up -d

# Ver se está rodando
docker ps
```

Deve aparecer: `evolution-api` com status `Up`

#### Passo 6: Testar

No seu navegador, acesse: `http://SEU_IP:8080`

Exemplo: `http://123.45.67.89:8080`

Se aparecer a página da Evolution API, está funcionando! 🎉

#### Passo 7: Conectar WhatsApp

1. Acesse: `http://SEU_IP:8080/instance/connect/minha-empresa`
2. Escanei o QR Code com seu WhatsApp
3. Pronto!

#### Passo 8: Configurar no Sistema

No seu sistema, em **Configurações da Empresa**:

- **Provedor**: `Evolution API`
- **URL da API**: `http://SEU_IP:8080` (ex: `http://123.45.67.89:8080`)
- **API Key**: `SUA_CHAVE_SECRETA_AQUI_123456` (a mesma do docker-compose.yml)
- **ID da Instância**: `minha-empresa`
- **Número de Origem**: `5511999999999` (seu WhatsApp com DDI)

---

## 🔒 Deixando Seguro com HTTPS (Opcional)

Se você tem um domínio (ex: `api.minhaempresa.com`), pode configurar HTTPS:

### Passo 1: Apontar Domínio para o IP

No seu provedor de domínio (Registro.br, GoDaddy, etc):

1. Crie um registro **A**:
   - Nome: `api`
   - Tipo: `A`
   - Valor: `SEU_IP` (ex: `123.45.67.89`)
   - TTL: `3600`

Aguarde 5-10 minutos para propagar.

### Passo 2: Instalar Nginx + Certbot

```bash
# Instalar Nginx
apt install nginx -y

# Instalar Certbot (para SSL grátis)
apt install certbot python3-certbot-nginx -y

# Configurar domínio
nano /etc/nginx/sites-available/evolution
```

Cole:

```nginx
server {
    listen 80;
    server_name api.minhaempresa.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Salve e:

```bash
# Ativar configuração
ln -s /etc/nginx/sites-available/evolution /etc/nginx/sites-enabled/

# Testar configuração
nginx -t

# Reiniciar Nginx
systemctl restart nginx

# Obter certificado SSL (HTTPS)
certbot --nginx -d api.minhaempresa.com
```

Siga as instruções do Certbot (só apertar ENTER).

Agora sua API está em: `https://api.minhaempresa.com` 🔒

---

## ✅ Testando se Funciona

### Teste 1: API está online?

Abra o navegador em: `http://SEU_IP:8080` ou `https://seu-dominio.com`

Deve mostrar página da Evolution API.

### Teste 2: WhatsApp está conectado?

Acesse: `http://SEU_IP:8080/instance/connect/minha-empresa`

Deve mostrar:
- ✅ "Connected" = Conectado
- ❌ QR Code = Não conectado (escaneie novamente)

### Teste 3: Enviar mensagem de teste

Use o Postman ou curl:

```bash
curl -X POST http://SEU_IP:8080/message/sendText/minha-empresa \
  -H "apikey: SUA_CHAVE_SECRETA_AQUI_123456" \
  -H "Content-Type: application/json" \
  -d '{
    "number": "5511999999999",
    "text": "Teste de mensagem!"
  }'
```

Se recebeu a mensagem no WhatsApp, está funcionando! 🎉

---

## 🆘 Problemas Comuns

### "Não consigo acessar http://SEU_IP:8080"

**Solução:**
```bash
# Liberar porta no firewall
ufw allow 8080/tcp
ufw reload
```

### "QR Code não carrega"

**Solução:**
```bash
# Reiniciar Evolution
cd /opt/evolution-api
docker-compose restart
```

### "WhatsApp desconecta sozinho"

**Causas:**
- WhatsApp no celular foi desinstalado
- Sessão expirou (normal após 15-30 dias)

**Solução:** Escanear QR Code novamente

### "Erro ao enviar mensagem"

Verificar:
1. WhatsApp está conectado?
2. Número está correto? (com DDI: 55)
3. API Key está correta?

---

## 📱 Usando no Sistema

Depois de tudo configurado:

1. Vá em **Vendas**
2. Abra uma venda **FINALIZADA**
3. Clique em **📱 Enviar WhatsApp**
4. Confirme
5. ✅ PDF enviado automaticamente!

---

## 💰 Resumo de Custos

| Opção | Custo | Quando Usar |
|-------|-------|-------------|
| Computador Local | R$ 0 | Apenas testes |
| VPS Básico | R$ 25/mês | Produção pequena |
| VPS Premium | R$ 50-100/mês | Muitos envios |
| Serviço Pronto | R$ 50-150/mês | Não quer configurar |

---

## 📞 Precisa de Ajuda?

- **Documentação Evolution**: https://doc.evolution-api.com/
- **Grupo Telegram Evolution**: https://t.me/evolutionapi
- **Vídeos YouTube**: Procure por "Evolution API tutorial"

---

✨ **Seguiu todos os passos e deu certo? Parabéns! Agora você pode enviar PDFs automaticamente!** 🚀
