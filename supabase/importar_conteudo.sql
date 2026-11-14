-- =============================================================================
-- Importa o conteúdo das tabelas importacao_* para as tabelas do app.
--
-- Antes: importar os CSV da planilha de curadoria em importacao_trilhas,
-- importacao_aulas e importacao_conteudos (veja conteudo/README.md).
-- Pode rodar quantas vezes quiser: atualiza o que já existe pela chave
-- (trilha_id, número da aula) e não duplica nada.
-- =============================================================================

-- 1. Trilhas (novas ou atualizadas)
insert into public.trilhas (id, origem, titulo, total_aulas, gratis, certificado, video, offline, ordem)
select lower(trim(trilha_id)), trim(origem), trim(titulo), total_aulas,
       lower(trim(coalesce(gratis, '')))      in ('sim', 's', 'x', 'true', '1'),
       lower(trim(coalesce(certificado, ''))) in ('sim', 's', 'x', 'true', '1'),
       lower(trim(coalesce(video, '')))       in ('sim', 's', 'x', 'true', '1'),
       lower(trim(coalesce(offline, '')))     in ('sim', 's', 'x', 'true', '1'),
       coalesce(ordem, 0)
  from public.importacao_trilhas
 where coalesce(trim(trilha_id), '') <> ''
on conflict (id) do update set
  origem = excluded.origem, titulo = excluded.titulo,
  total_aulas = excluded.total_aulas, gratis = excluded.gratis,
  certificado = excluded.certificado, video = excluded.video,
  offline = excluded.offline, ordem = excluded.ordem;

-- 2. Aulas (pela trilha + número da aula)
insert into public.aulas (trilha_id, numero, titulo, fonte, url, gratis, certificado, video, minutos, ementa)
select lower(trim(trilha_id)), numero, trim(titulo), trim(fonte), nullif(trim(url), ''),
       lower(trim(coalesce(gratis, '')))      in ('sim', 's', 'x', 'true', '1'),
       lower(trim(coalesce(certificado, ''))) in ('sim', 's', 'x', 'true', '1'),
       lower(trim(coalesce(video, '')))       in ('sim', 's', 'x', 'true', '1'),
       minutos, trim(ementa)
  from public.importacao_aulas
 where coalesce(trim(trilha_id), '') <> '' and numero is not null
on conflict (trilha_id, numero) do update set
  titulo = excluded.titulo, fonte = excluded.fonte, url = excluded.url,
  gratis = excluded.gratis, certificado = excluded.certificado,
  video = excluded.video, minutos = excluded.minutos, ementa = excluded.ementa;

-- 3. Conteúdos relacionados: troca os das aulas que vieram na planilha
delete from public.conteudos_relacionados c
 using public.aulas a
 where c.aula_id = a.id
   and exists (select 1 from public.importacao_conteudos i
                where lower(trim(i.trilha_id)) = a.trilha_id
                  and i.aula_numero = a.numero);

insert into public.conteudos_relacionados (aula_id, titulo, subtitulo, tipo, url, ordem)
select a.id, trim(i.titulo), trim(i.subtitulo), lower(trim(i.tipo)),
       nullif(trim(i.url), ''), coalesce(i.ordem, 0)
  from public.importacao_conteudos i
  join public.aulas a
    on a.trilha_id = lower(trim(i.trilha_id)) and a.numero = i.aula_numero
 where coalesce(trim(i.titulo), '') <> '';

-- 4. Conferência (é o resultado que aparece embaixo, em Results).
--    "ok" = tudo entrou. Qualquer outra linha = corrigir na planilha e
--    importar de novo. Para a próxima leva, esvazie antes as tabelas:
--      truncate public.importacao_trilhas, public.importacao_aulas,
--               public.importacao_conteudos;
select 'aula sem trilha' as problema, i.trilha_id, i.numero::text as aula, i.titulo
  from public.importacao_aulas i
 where not exists (select 1 from public.trilhas t where t.id = lower(trim(i.trilha_id)))
union all
select 'conteúdo sem aula', i.trilha_id, i.aula_numero::text, i.titulo
  from public.importacao_conteudos i
 where not exists (select 1 from public.aulas a
                    where a.trilha_id = lower(trim(i.trilha_id)) and a.numero = i.aula_numero)
union all
select 'ok', t.id, count(a.id)::text || ' de ' || t.total_aulas || ' aulas', t.titulo
  from public.trilhas t
  left join public.aulas a on a.trilha_id = t.id
 group by t.id, t.titulo, t.total_aulas;
