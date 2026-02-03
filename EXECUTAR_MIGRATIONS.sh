#!/bin/bash
# Script para executar migrations no Supabase

echo "🚀 Iniciando processo de migração..."
echo ""

# URLs e credenciais
SUPABASE_URL="https://seu-projeto.supabase.co"
SUPABASE_API_KEY="sua-api-key-aqui"

# Migration 003: Adicionar colunas em PRODUTOS
echo "📝 Executando Migration 003: Adicionar colunas PRODUTOS..."
echo "   Arquivo: database/migrations/003_adicionar_cfop_compra.sql"
echo ""
echo "   ⚠️  Instruções Manuais:"
echo "   1. Abrir: https://app.supabase.com"
echo "   2. Selecionar seu projeto"
echo "   3. Ir para: SQL Editor"
echo "   4. Novo Query"
echo "   5. Copiar conteúdo de: database/migrations/003_adicionar_cfop_compra.sql"
echo "   6. Clicar RUN"
echo "   7. Aguardar conclusão (deve levar alguns segundos)"
echo ""

# Migration 004: Adicionar coluna TROCO em VENDAS
echo "📝 Executando Migration 004: Adicionar TROCO em VENDAS..."
echo "   Arquivo: database/migrations/004_adicionar_troco_vendas.sql"
echo ""
echo "   ⚠️  Instruções Manuais:"
echo "   1. Abrir: https://app.supabase.com"
echo "   2. Selecionar seu projeto"
echo "   3. Ir para: SQL Editor"
echo "   4. Novo Query"
echo "   5. Copiar conteúdo de: database/migrations/004_adicionar_troco_vendas.sql"
echo "   6. Clicar RUN"
echo "   7. Aguardar conclusão"
echo ""

echo "✅ Processo concluído!"
echo ""
echo "Próximas etapas:"
echo "1. Voltar para PDV"
echo "2. Testar finalizar venda"
echo "3. Verificar se o erro de 'troco' foi resolvido"
