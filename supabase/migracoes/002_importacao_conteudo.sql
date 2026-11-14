-- 002 · Tabelas de importação do conteúdo (planilha → banco)
--
-- O grupo preenche a planilha de curadoria (pasta conteudo/ do repositório),
-- exporta cada aba como CSV e importa nestas tabelas pelo painel:
--   Table Editor → importacao_... → Insert → Import data from CSV
-- Depois roda supabase/importar_conteudo.sql, que copia tudo para as
-- tabelas do app e esvazia estas.
--
-- Sim/não nas colunas gratis, certificado, video e offline: escreva "sim"
-- ou "não" (também aceita s, x, true, 1).

create table if not exists public.importacao_trilhas (
  trilha_id text,
  origem text,
  titulo text,
  total_aulas int,
  gratis text,
  certificado text,
  video text,
  offline text,
  ordem int
);

create table if not exists public.importacao_aulas (
  trilha_id text,
  numero int,
  titulo text,
  fonte text,
  url text,
  gratis text,
  certificado text,
  video text,
  minutos int,
  ementa text
);

create table if not exists public.importacao_conteudos (
  trilha_id text,
  aula_numero int,
  ordem int,
  titulo text,
  subtitulo text,
  tipo text,
  url text
);

-- Sem políticas: só o painel do Supabase mexe nelas, o app não enxerga.
alter table public.importacao_trilhas enable row level security;
alter table public.importacao_aulas enable row level security;
alter table public.importacao_conteudos enable row level security;
