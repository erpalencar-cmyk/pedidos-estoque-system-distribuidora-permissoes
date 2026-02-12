-- =====================================================
-- OPCIONAL: Inserir Admin com TODAS as permissões
-- =====================================================
-- Isso é OPCIONAL porque o PermissaoManager agora verifica:
-- IF role = ADMIN → acesso total automaticamente
--
-- Mas é bom ter registros na tabela para documentação

-- 1. Encontra o admin (substitua pelo email real do seu admin)
-- SELECT id FROM users WHERE email = 'seu-email-admin@gmail.com' AND role = 'ADMIN';

-- 2. Insere permissões para TODOS os módulos (se quiser fazer manualmente)
-- Exemplo para um admin específico:
-- INSERT INTO usuarios_modulos (usuario_id, modulo_id, pode_acessar, pode_criar, pode_editar, pode_deletar)
-- SELECT 
--     'ADMIN_USER_ID_AQUI'::uuid,
--     id,
--     true, true, true, true
-- FROM modulos
-- ON CONFLICT (usuario_id, modulo_id) DO NOTHING;

-- =====================================================
-- IMPORTANTE: Admin NÃO precisa de registros em usuarios_modulos
-- =====================================================
-- O sistema agora verifica:
-- 1. IF user.role = 'ADMIN' → retorna TRUE automaticamente
-- 2. Caso contrário, consulta usuarios_modulos table
--
-- Isso significa que ADMIN:
-- ✅ Sempre vê TODOS os módulos
-- ✅ Pode fazer tudo (criar, editar, deletar)
-- ✅ Não precisa estar em usuarios_modulos
-- ✅ Acesso instantâneo, sem queries extras

-- Se você quiser criar registros de admin:
-- 1. Identifique o UID do admin: SELECT id FROM users WHERE role = 'ADMIN';
-- 2. Crie permissões para ela em todos os módulos (veja exemplo acima)
-- 3. Ou deixe em branco - o sistema dá acesso total automaticamente
