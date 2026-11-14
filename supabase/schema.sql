-- =============================================================================
-- JornadaTech · estrutura do banco (Supabase / PostgreSQL)
--
-- Como usar: Supabase → SQL Editor → New query → colar este arquivo → Run.
-- ATENÇÃO: rodar de novo APAGA e recria as tabelas do app (perfis, progresso,
-- favoritos e catálogo). Use só enquanto o app está em teste; depois disso,
-- mudanças viram arquivos novos em supabase/ (migrações).
--
-- LGPD: nenhuma tabela guarda nome real, CPF ou e-mail. O aluno é só um
-- nome de usuário aleatório (ex.: CorujaAzul42). Senha e código de recuperação
-- ficam apenas como hash (bcrypt).
-- =============================================================================

create extension if not exists pgcrypto with schema extensions;

drop table if exists public.favoritos cascade;
drop table if exists public.progresso cascade;
drop table if exists public.conteudos_relacionados cascade;
drop table if exists public.aulas cascade;
drop table if exists public.trilhas cascade;
drop table if exists public.perfis cascade;

-- -----------------------------------------------------------------------------
-- Perfis: 1 por conta. Criado sozinho quando a conta nasce (gatilho abaixo).
-- -----------------------------------------------------------------------------
create table public.perfis (
  id uuid primary key references auth.users (id) on delete cascade,
  nome_usuario text not null check (nome_usuario ~ '^[A-Za-z]{3,30}[0-9]{2}$'),
  papel text not null default 'aluno' check (papel in ('aluno', 'monitor')),
  codigo_recuperacao_hash text,
  tentativas_falhas int not null default 0,
  bloqueado_ate timestamptz,
  criado_em timestamptz not null default now()
);
create unique index perfis_nome_usuario_unico on public.perfis (lower(nome_usuario));

-- -----------------------------------------------------------------------------
-- Catálogo: trilhas, aulas e conteúdos relacionados (leitura pública).
-- -----------------------------------------------------------------------------
create table public.trilhas (
  id text primary key,                       -- ex.: 'bd-sql'
  origem text not null,                      -- ex.: 'Cesuca · Fundamentos de BD'
  titulo text not null,
  total_aulas int not null check (total_aulas > 0), -- tamanho previsto da trilha
  gratis boolean not null default true,
  certificado boolean not null default false,
  video boolean not null default false,
  offline boolean not null default false,
  ordem int not null default 0
);

create table public.aulas (
  id uuid primary key default gen_random_uuid(),
  trilha_id text not null references public.trilhas (id) on delete cascade,
  numero int not null check (numero > 0),
  titulo text not null,
  fonte text not null,                       -- ex.: 'YouTube', 'MDN Web Docs'
  url text,
  gratis boolean not null default true,
  certificado boolean not null default false,
  video boolean not null default true,
  minutos int not null check (minutos > 0),
  ementa text not null,                      -- bloco "Cobre da ementa"
  unique (trilha_id, numero)
);

create table public.conteudos_relacionados (
  id uuid primary key default gen_random_uuid(),
  aula_id uuid not null references public.aulas (id) on delete cascade,
  titulo text not null,
  subtitulo text not null,                   -- ex.: 'Curso · 12h · com certificado'
  tipo text not null check (tipo in ('site', 'curso', 'video')),
  url text,
  ordem int not null default 0
);

-- -----------------------------------------------------------------------------
-- Dados do aluno: progresso por aula e trilhas favoritas.
-- -----------------------------------------------------------------------------
create table public.progresso (
  usuario_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  aula_id uuid not null references public.aulas (id) on delete cascade,
  status text not null check (status in ('nao_visto', 'visto', 'concluido')),
  atualizado_em timestamptz not null default now(),
  primary key (usuario_id, aula_id)
);

create table public.favoritos (
  usuario_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  trilha_id text not null references public.trilhas (id) on delete cascade,
  criado_em timestamptz not null default now(),
  primary key (usuario_id, trilha_id)
);

-- -----------------------------------------------------------------------------
-- Segurança (RLS): cada aluno só vê e altera os próprios dados.
-- -----------------------------------------------------------------------------
alter table public.perfis enable row level security;
alter table public.trilhas enable row level security;
alter table public.aulas enable row level security;
alter table public.conteudos_relacionados enable row level security;
alter table public.progresso enable row level security;
alter table public.favoritos enable row level security;

create policy "catalogo publico" on public.trilhas for select using (true);
create policy "catalogo publico" on public.aulas for select using (true);
create policy "catalogo publico" on public.conteudos_relacionados for select using (true);

create policy "le o proprio perfil" on public.perfis
  for select to authenticated using (id = auth.uid());

create policy "proprio progresso" on public.progresso
  for all to authenticated
  using (usuario_id = auth.uid()) with check (usuario_id = auth.uid());

create policy "proprios favoritos" on public.favoritos
  for all to authenticated
  using (usuario_id = auth.uid()) with check (usuario_id = auth.uid());

-- -----------------------------------------------------------------------------
-- Gatilho: quando a conta é criada, cria o perfil com o nome de usuário.
-- O app manda o nome em options.data.nome_usuario no signUp.
-- -----------------------------------------------------------------------------
create or replace function public.criar_perfil()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.perfis (id, nome_usuario)
  values (new.id, new.raw_user_meta_data ->> 'nome_usuario');
  return new;
end;
$$;

drop trigger if exists ao_criar_conta on auth.users;
create trigger ao_criar_conta
  after insert on auth.users
  for each row execute function public.criar_perfil();

-- -----------------------------------------------------------------------------
-- Funções chamadas pelo app (rpc).
-- -----------------------------------------------------------------------------

-- O nome sugerido ainda está livre? (usada antes de criar a conta)
create or replace function public.nome_usuario_disponivel(nome text)
returns boolean
language sql
security definer set search_path = ''
stable
as $$
  select not exists (
    select 1 from public.perfis where lower(nome_usuario) = lower(trim(nome))
  );
$$;

-- Guarda o código de recuperação (só o hash) da conta logada.
create or replace function public.definir_codigo_recuperacao(codigo text)
returns void
language plpgsql
security definer set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'não autenticado';
  end if;
  update public.perfis
     set codigo_recuperacao_hash =
           extensions.crypt(upper(codigo), extensions.gen_salt('bf'))
   where id = auth.uid();
end;
$$;

-- "Esqueci minha senha": confere nome + código e troca a senha.
-- Depois de 5 tentativas erradas, bloqueia por 15 minutos.
-- Devolve: 'ok' | 'invalido' | 'bloqueado' | 'senha_fraca'
create or replace function public.redefinir_senha_com_codigo(
  nome text, codigo text, nova_senha text, novo_codigo text
)
returns text
language plpgsql
security definer set search_path = ''
as $$
declare
  p public.perfis%rowtype;
begin
  select * into p from public.perfis
   where lower(nome_usuario) = lower(trim(nome));

  if not found or p.codigo_recuperacao_hash is null then
    return 'invalido';
  end if;
  if p.bloqueado_ate is not null and p.bloqueado_ate > now() then
    return 'bloqueado';
  end if;
  if p.codigo_recuperacao_hash <>
       extensions.crypt(upper(codigo), p.codigo_recuperacao_hash) then
    update public.perfis
       set tentativas_falhas = tentativas_falhas + 1,
           bloqueado_ate = case when tentativas_falhas + 1 >= 5
                                then now() + interval '15 minutes' end
     where id = p.id;
    return 'invalido';
  end if;
  if length(nova_senha) < 8
     or nova_senha !~ '[A-Za-z]' or nova_senha !~ '[0-9]' then
    return 'senha_fraca';
  end if;

  update auth.users
     set encrypted_password = extensions.crypt(nova_senha, extensions.gen_salt('bf')),
         updated_at = now()
   where id = p.id;

  -- o código usado deixa de valer
  update public.perfis
     set codigo_recuperacao_hash =
           extensions.crypt(upper(novo_codigo), extensions.gen_salt('bf')),
         tentativas_falhas = 0,
         bloqueado_ate = null
   where id = p.id;

  return 'ok';
end;
$$;

revoke all on function public.nome_usuario_disponivel(text) from public;
revoke all on function public.definir_codigo_recuperacao(text) from public;
revoke all on function public.redefinir_senha_com_codigo(text, text, text, text) from public;
grant execute on function public.nome_usuario_disponivel(text) to anon, authenticated;
grant execute on function public.definir_codigo_recuperacao(text) to authenticated;
grant execute on function public.redefinir_senha_com_codigo(text, text, text, text) to anon, authenticated;
