-- 001 · Perfil criado mesmo sem o nome nos metadados
-- (ex.: conta criada pelo painel do Supabase). Já incluído no schema.sql;
-- rode este arquivo só se o banco foi criado antes desta mudança.

create or replace function public.criar_perfil()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.perfis (id, nome_usuario)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'nome_usuario', split_part(new.email, '@', 1))
  );
  return new;
end;
$$;
