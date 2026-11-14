-- =============================================================================
-- JornadaTech · dados de exemplo (as mesmas 3 trilhas que o app mostra hoje)
--
-- Como usar: depois do schema.sql, SQL Editor → colar este arquivo → Run.
-- Pode rodar de novo: apaga o catálogo e insere outra vez.
-- O conteúdo real das trilhas vem da curadoria do grupo (Leo e Andrius).
-- =============================================================================

delete from public.trilhas;

insert into public.trilhas (id, origem, titulo, total_aulas, gratis, certificado, video, offline, ordem) values
  ('logica',    'Metamorfose · Módulo 2',     'Lógica de Programação',    12, true,  false, true, true,  1),
  ('bd-sql',    'Cesuca · Fundamentos de BD', 'Banco de Dados & SQL',     11, true,  false, true, false, 2),
  ('front-end', 'Metamorfose · Módulo 4',     'Front-end com HTML e CSS', 10, false, true,  true, false, 3);

with nova as (
  insert into public.aulas (trilha_id, numero, titulo, fonte, gratis, certificado, video, minutos, ementa) values
    ('logica', 10, 'Laços de repetição: for e while na prática', 'YouTube', true, false, true, 24,
     'Unidade 4 — Estruturas de repetição. Reforça o que foi visto em aula com exercícios resolvidos passo a passo.'),
    ('bd-sql', 5, 'Consultas com JOIN: unindo tabelas na prática', 'YouTube', true, false, true, 32,
     'Unidade 3 — Álgebra relacional e consultas multi-tabela. Aprofunda o que foi visto em aula com exemplos reais e exercícios.'),
    ('front-end', 1, 'Sua primeira página com HTML semântico', 'MDN Web Docs', true, true, false, 40,
     'Unidade 1 — Estrutura de documentos HTML. Base para os exercícios de layout das próximas aulas.')
  returning id, trilha_id
)
insert into public.conteudos_relacionados (aula_id, titulo, subtitulo, tipo, ordem)
select nova.id, r.titulo, r.subtitulo, r.tipo, r.ordem
from nova
join (values
  ('logica',    'Beecrowd — exercícios iniciantes',  'Site',                            'site',  1),
  ('logica',    'Curso Lógica com Python',           'Curso · 20h · com certificado',   'curso', 2),
  ('logica',    'Algoritmos explicados (playlist)',  'YouTube · 1h10',                  'video', 3),
  ('bd-sql',    'SQL Zoo — exercícios guiados',      'Site',                            'site',  1),
  ('bd-sql',    'Curso Modelagem Relacional',        'Curso · 12h · com certificado',   'curso', 2),
  ('bd-sql',    'JOINs na prática (playlist)',       'YouTube · 48min',                 'video', 3),
  ('front-end', 'Guia de CSS Flexbox',               'Site',                            'site',  1),
  ('front-end', 'Curso Responsive Web Design',       'Curso · 300h · com certificado',  'curso', 2),
  ('front-end', 'HTML e CSS do zero (playlist)',     'YouTube · 2h',                    'video', 3)
) as r (trilha_id, titulo, subtitulo, tipo, ordem) on r.trilha_id = nova.trilha_id;
