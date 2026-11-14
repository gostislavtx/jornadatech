# Curadoria do conteúdo

Aqui ficam os **modelos da planilha** que o grupo preenche com as trilhas e aulas reais. Cada arquivo `.csv` vira uma aba da planilha e depois é importado no banco (Supabase).

## Como funciona

1. **Copie os modelos para uma planilha no Google Sheets** (uma aba por arquivo: `trilhas`, `aulas`, `conteudos`). Em cada aba: *Arquivo → Importar → Fazer upload* do `.csv`. A primeira linha (cabeçalho) **não pode mudar**; a segunda é só exemplo, pode apagar.
2. **Preencha** as aulas de cada trilha seguindo os critérios de curadoria (abaixo).
3. **Revisão:** outra pessoa do grupo confere os links e a ementa.
4. **Importação (quem cuida do banco):** em cada aba, *Arquivo → Fazer download → CSV*. No Supabase, *Table Editor → `importacao_trilhas` / `importacao_aulas` / `importacao_conteudos` → Insert → Import data from CSV*. Depois, rodar [`supabase/importar_conteudo.sql`](../supabase/importar_conteudo.sql) no SQL Editor.
5. O resultado mostra `ok` com quantas aulas cada trilha tem. Qualquer outra linha é algo para corrigir na planilha.

## Colunas

### `trilhas`
| Coluna | O que colocar | Exemplo |
|---|---|---|
| `trilha_id` | Código curto, minúsculo, sem espaço nem acento | `logica` |
| `origem` | De onde vem a trilha | `Metamorfose · Módulo 2` |
| `titulo` | Nome da trilha | `Lógica de Programação` |
| `total_aulas` | Quantas aulas a trilha terá | `12` |
| `gratis`, `certificado`, `video`, `offline` | `sim` ou `não` (para os filtros da home) | `sim` |
| `ordem` | Posição na lista da home | `1` |

### `aulas`
| Coluna | O que colocar | Exemplo |
|---|---|---|
| `trilha_id` | O mesmo código da aba `trilhas` | `logica` |
| `numero` | 1, 2, 3… na ordem em que o aluno deve estudar | `1` |
| `titulo` | Nome da aula | `Variáveis e tipos de dados` |
| `fonte` | Onde está o conteúdo | `YouTube`, `MDN Web Docs`, `Curso em Vídeo` |
| `url` | Link direto do conteúdo | `https://…` |
| `gratis`, `certificado`, `video` | `sim` ou `não` | `sim` |
| `minutos` | Duração aproximada | `20` |
| `ementa` | Bloco "Cobre da ementa": unidade da disciplina + o que a aula aprofunda (1 a 2 frases) | `Unidade 1 — Algoritmos e variáveis…` |

### `conteudos` ("Continue nesta trilha", até 3 por aula)
| Coluna | O que colocar | Exemplo |
|---|---|---|
| `trilha_id`, `aula_numero` | De qual aula é | `logica`, `1` |
| `ordem` | 1, 2 ou 3 | `1` |
| `titulo` | Nome do conteúdo extra | `Beecrowd — exercícios iniciantes` |
| `subtitulo` | Tipo e detalhe | `Site`, `Curso · 20h · com certificado`, `YouTube · 48min` |
| `tipo` | `site`, `curso` ou `video` | `site` |
| `url` | Link | `https://…` |

## Critérios de curadoria

Os mesmos da pesquisa apresentada na Mostra:

- **Confiabilidade:** canal, site ou instituição conhecida (documentação oficial, universidades, criadores reconhecidos).
- **Gratuidade:** o aluno consegue acessar sem pagar (se o certificado for pago, marque `certificado` = `não`).
- **Atualização:** conteúdo dos últimos anos e que ainda funciona (versões atuais das ferramentas).
- **Dificuldade:** combina com o nível do aluno do Metamorfose e segue a ordem da ementa.

Prefira **poucos conteúdos excelentes** por aula a muitos médios.
