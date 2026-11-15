-- =============================================================================
-- Conta de demonstração: CorujaAzul42 / trilha2026 (código K7M2-QX9P)
--
-- 1. Authentication → Users → Add user → Create new user:
--      Email:    corujaazul42@alunos.jornadatech.dev.br
--      Password: trilha2026
--      Auto Confirm User: marcado
-- 2. SQL Editor → colar este arquivo → Run.
-- =============================================================================

update auth.users
   set raw_user_meta_data =
         coalesce(raw_user_meta_data, '{}'::jsonb) || '{"nome_usuario": "CorujaAzul42"}'::jsonb
 where email = 'corujaazul42@alunos.jornadatech.dev.br';

update public.perfis
   set nome_usuario = 'CorujaAzul42',
       codigo_recuperacao_hash = extensions.crypt('K7M2-QX9P', extensions.gen_salt('bf'))
 where id = (select id from auth.users
              where email = 'corujaazul42@alunos.jornadatech.dev.br');

-- Confere: deve mostrar 1 linha com CorujaAzul42.
select nome_usuario, papel, criado_em from public.perfis;
