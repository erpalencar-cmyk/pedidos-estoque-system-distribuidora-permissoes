-- =====================================================
-- MIGRATION 002: Corrigir módulos duplicados
-- =====================================================
-- Problema: A migration 001 criou módulos novos com slugs corretos,
-- mas os módulos antigos (com slugs diferentes) já tinham permissões
-- vinculadas via usuarios_modulos. Resultado: sidebar não reconhece os
-- slugs antigos e não mostra os módulos.
--
-- Solução: Migrar permissões dos módulos antigos para os novos,
-- depois remover os módulos antigos duplicados.
-- =====================================================

DO $$
DECLARE
    v_old_id UUID;
    v_new_id UUID;
    v_count INTEGER;
    r RECORD;
BEGIN
    -- Mapear slugs antigos → slugs corretos (que o sidebar usa)
    FOR r IN
        SELECT * FROM (VALUES
            ('analises-financeiras',  'analise-financeira'),
            ('configuracoes',         'configuracoes-empresa')
        ) AS t(old_slug, new_slug)
    LOOP
        -- Encontrar IDs dos módulos antigo e novo
        SELECT id INTO v_old_id FROM public.modulos WHERE slug = r.old_slug;
        SELECT id INTO v_new_id FROM public.modulos WHERE slug = r.new_slug;

        IF v_old_id IS NULL THEN
            RAISE NOTICE 'Módulo antigo com slug "%" não encontrado, pulando.', r.old_slug;
            CONTINUE;
        END IF;

        IF v_new_id IS NULL THEN
            -- Novo módulo não existe: apenas renomear o slug do antigo
            RAISE NOTICE 'Módulo novo "%" não existe. Atualizando slug do antigo diretamente.', r.new_slug;
            UPDATE public.modulos
            SET slug = r.new_slug
            WHERE id = v_old_id;
            CONTINUE;
        END IF;

        -- Ambos existem: migrar permissões do antigo para o novo
        RAISE NOTICE 'Migrando permissões de "%" (%) para "%" (%)', r.old_slug, v_old_id, r.new_slug, v_new_id;

        -- Para cada permissão do módulo antigo...
        FOR v_count IN 1..1 LOOP
            -- Inserir permissões no módulo novo (se ainda não existem)
            INSERT INTO public.usuarios_modulos (usuario_id, modulo_id, pode_acessar, pode_criar, pode_editar, pode_deletar)
            SELECT um.usuario_id, v_new_id, um.pode_acessar, um.pode_criar, um.pode_editar, um.pode_deletar
            FROM public.usuarios_modulos um
            WHERE um.modulo_id = v_old_id
            ON CONFLICT (usuario_id, modulo_id) DO UPDATE SET
                pode_acessar = EXCLUDED.pode_acessar,
                pode_criar   = EXCLUDED.pode_criar,
                pode_editar  = EXCLUDED.pode_editar,
                pode_deletar = EXCLUDED.pode_deletar;
        END LOOP;

        -- Remover permissões do módulo antigo
        DELETE FROM public.usuarios_modulos WHERE modulo_id = v_old_id;

        -- Remover módulo antigo
        DELETE FROM public.modulos WHERE id = v_old_id;

        RAISE NOTICE 'Módulo antigo "%" removido com sucesso.', r.old_slug;
    END LOOP;

    RAISE NOTICE '✅ Limpeza de módulos duplicados concluída.';
END $$;

-- Verificação: listar todos os módulos ativos com seus slugs
-- SELECT id, nome, slug, ordem FROM public.modulos WHERE ativo = true ORDER BY ordem;
