# Banco de dados (Supabase)

O JornadaTech usa o [Supabase](https://supabase.com) (PostgreSQL) para contas, catálogo de trilhas, progresso e favoritos.

## Tabelas

| Tabela | O que guarda | Quem lê / escreve |
|---|---|---|
| `perfis` | Nome de usuário, papel (aluno/monitor), hash do código de recuperação | Cada um lê só o próprio |
| `trilhas` | Trilhas do catálogo (origem, título, total de aulas, filtros) | Leitura pública |
| `aulas` | Aulas de cada trilha (fonte, duração, "Cobre da ementa") | Leitura pública |
| `conteudos_relacionados` | "Continue nesta trilha" de cada aula | Leitura pública |
| `progresso` | Status de cada aula por aluno (não visto, visto, concluído) | Só o próprio aluno |
| `favoritos` | Trilhas favoritas de cada aluno | Só o próprio aluno |

Nenhuma tabela guarda nome real, CPF ou e-mail (veja **Privacidade e LGPD** no README principal).

## Login sem e-mail

O Supabase Auth exige e-mail, então o app cria um **e-mail interno que não existe**, a partir do nome de usuário: `corujaazul42@alunos.jornadatech.dev.br`. O aluno nunca vê isso. Por isso a confirmação de e-mail fica **desligada**.

A recuperação de senha é feita pela função `redefinir_senha_com_codigo`, que confere o nome de usuário e o código de recuperação (guardado só como hash). Depois de 5 tentativas erradas, a conta fica bloqueada por 15 minutos.

## Como configurar (uma vez)

1. Crie o projeto em [supabase.com](https://supabase.com) → **New project**, região **South America (São Paulo)**.
2. **SQL Editor → New query**: cole [`schema.sql`](schema.sql) e clique em **Run**.
3. Ainda no SQL Editor, cole [`seed.sql`](seed.sql) e clique em **Run** (trilhas de exemplo).
4. **Authentication → Sign In / Providers → Email**: desligue **Confirm email** e salve.
5. **Project Settings → API**: copie a **Project URL** e a chave **anon / publishable** e coloque em `lib/config/supabase_config.dart`.
6. *(Opcional)* Conta de demonstração `CorujaAzul42`: siga as instruções no topo de [`conta_demo.sql`](conta_demo.sql).

Mudanças no banco depois da primeira configuração ficam em [`migracoes/`](migracoes/), numeradas na ordem em que devem ser rodadas.

A chave **anon/publishable** pode ir no app: quem protege os dados são as regras de segurança (RLS) do `schema.sql`. A chave **service_role / secret nunca** vai no app nem no GitHub.
