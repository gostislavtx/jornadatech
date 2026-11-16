-- =============================================================================
-- JornadaTech · conteúdo inicial das 5 trilhas (curadoria de 15/11/2026)
--
-- Como usar: Supabase → SQL Editor → colar este arquivo inteiro → Run.
-- Pode rodar quantas vezes quiser: atualiza pela chave (trilha, número da
-- aula) e não duplica. Os mesmos dados estão em conteudo/*.csv, para a
-- planilha do grupo. Gerado por um script: para mudar uma aula, edite a
-- planilha e importe pelo importar_conteudo.sql, ou edite aqui e no CSV.
-- =============================================================================

begin;

-- 1. Tira as 3 trilhas de exemplo do seed.sql (as aulas e o progresso delas
--    saem junto, em cascata).
delete from public.trilhas where id in ('logica', 'bd-sql', 'front-end');

-- 2. Trilhas
insert into public.trilhas (id, origem, titulo, total_aulas, gratis, certificado, video, offline, ordem) values
  ('fundamentos_informatica', 'Projeto Metamorfose', 'Fundamentos da Informática', 3, true, true, true, false, 1),
  ('produtividade_digital', 'Projeto Metamorfose', 'Produtividade Digital', 3, true, true, true, false, 2),
  ('ferramentas_google', 'Projeto Metamorfose', 'Ferramentas Google', 4, true, false, false, false, 3),
  ('hardware', 'Projeto Metamorfose', 'Hardware e Arquitetura de Computadores', 4, true, true, true, false, 4),
  ('desenvolvimento_web', 'Projeto Metamorfose', 'Introdução ao Desenvolvimento Web', 4, true, true, true, false, 5)
on conflict (id) do update set
  origem = excluded.origem, titulo = excluded.titulo,
  total_aulas = excluded.total_aulas, gratis = excluded.gratis,
  certificado = excluded.certificado, video = excluded.video,
  offline = excluded.offline, ordem = excluded.ordem;

-- 3. Aulas
insert into public.aulas (trilha_id, numero, titulo, fonte, url, gratis, certificado, video, minutos, ementa) values
  ('fundamentos_informatica', 1, 'Hardware e software: as partes do computador', 'Cursa (vídeos)',
   'https://cursa.app/pt/curso-gratuito/nocoes-de-hardware-bbaf', true, true, true, 30,
   'Unidade 1 — O computador. Mostra o que é hardware e software e para que serve cada peça (processador, memória, armazenamento, entrada e saída).'),
  ('fundamentos_informatica', 2, 'Como a internet e a web funcionam', 'MDN Web Docs',
   'https://developer.mozilla.org/pt-BR/docs/Learn_web_development/Getting_started/Web_standards/How_the_web_works', true, false, false, 15,
   'Unidade 2 — Internet. Explica, com uma comparação simples, o caminho de uma página da web do servidor até o seu navegador.'),
  ('fundamentos_informatica', 3, 'Segurança na internet: senhas, golpes e privacidade', 'Cartilha CERT.br',
   'https://cartilha.cert.br/dicas-rapidas/', true, false, false, 20,
   'Unidade 3 — Uso seguro. Dicas rápidas do CERT.br para criar senhas fortes, reconhecer golpes e proteger seus dados e dispositivos.'),
  ('produtividade_digital', 1, 'Organizando arquivos e pastas', 'MDN Web Docs',
   'https://developer.mozilla.org/pt-BR/docs/Learn_web_development/Getting_started/Environment_setup/Dealing_with_files', true, false, false, 15,
   'Unidade 1 — Arquivos. Como nomear arquivos e organizar pastas para achar tudo depois, no computador e na nuvem.'),
  ('produtividade_digital', 2, 'Editor de texto: Word do básico ao trabalho escolar', 'Curso em Vídeo (via Cursa)',
   'https://cursa.app/pt/curso-gratuito/word-ji', true, true, true, 40,
   'Unidade 2 — Documentos. Digitação, formatação, imagens, cabeçalho e sumário automático para entregar trabalhos bem apresentados.'),
  ('produtividade_digital', 3, 'Planilhas: Excel essencial', 'Curso em Vídeo (via Cursa)',
   'https://cursa.app/pt/curso-gratuito/excel-essencial-jh', true, true, true, 45,
   'Unidade 3 — Planilhas. Primeiros passos, formatação, classificação de dados e as primeiras funções, como SOMA e SE.'),
  ('ferramentas_google', 1, 'Gmail: e-mail organizado', 'Centro de aprendizagem do Google',
   'https://support.google.com/a/users/answer/9259748?hl=pt-BR', true, false, false, 20,
   'Unidade 1 — Comunicação. Enviar e responder e-mails, anexar arquivos e organizar a caixa de entrada com marcadores.'),
  ('ferramentas_google', 2, 'Google Drive: guardar e compartilhar arquivos', 'Centro de aprendizagem do Google',
   'https://support.google.com/a/users/answer/9282958?hl=pt-BR', true, false, false, 20,
   'Unidade 2 — Nuvem. Enviar arquivos, criar pastas e compartilhar com colegas e professores sem perder o controle de quem acessa.'),
  ('ferramentas_google', 3, 'Google Documentos: escrever em equipe', 'Centro de aprendizagem do Google',
   'https://support.google.com/a/users/answer/9282664?hl=pt-BR', true, false, false, 25,
   'Unidade 3 — Documentos. Criar, formatar e editar ao mesmo tempo com o grupo, com comentários e histórico de versões.'),
  ('ferramentas_google', 4, 'Google Planilhas e Formulários', 'Centro de aprendizagem do Google',
   'https://support.google.com/a/users/answer/9282959?hl=pt-BR', true, false, false, 30,
   'Unidade 4 — Dados. Montar uma planilha simples e coletar respostas com um formulário que preenche a planilha sozinho.'),
  ('hardware', 1, 'Os componentes de um computador', 'Curso em Vídeo',
   'https://www.youtube.com/playlist?list=PLHz_AreHm4dn1JHgN9wpbIUhzZmycYQXW', true, true, true, 40,
   'Unidade 1 — Componentes. Processador, placa-mãe, memória, armazenamento e fonte: o que cada um faz e como escolher.'),
  ('hardware', 2, 'Montagem e manutenção do computador', 'Cursa (vídeos)',
   'https://cursa.app/pt/curso-gratuito/montagem-e-manutencao-de-computadores-hcb', true, true, true, 45,
   'Unidade 2 — Montagem. Cuidados com eletricidade estática, encaixe das peças, ligação dos cabos e diagnóstico de problemas comuns.'),
  ('hardware', 3, 'Redes de computadores', 'Curso em Vídeo',
   'https://www.youtube.com/playlist?list=PLHz_AreHm4dkd4lr9G0Up-W-YaHYdTDuP', true, true, true, 40,
   'Unidade 3 — Redes. Como os computadores se conectam: cabos, Wi-Fi, roteador, endereço IP e internet.'),
  ('hardware', 4, 'Sistema operacional: Linux', 'Curso em Vídeo',
   'https://www.youtube.com/playlist?list=PLHz_AreHm4dlIXleu20uwPWFOSswqLYbV', true, true, true, 40,
   'Unidade 4 — Software básico. O papel do sistema operacional entre o hardware e os programas, na prática com o Linux.'),
  ('desenvolvimento_web', 1, 'Introdução à Web: seu primeiro site', 'MDN Web Docs',
   'https://developer.mozilla.org/pt-BR/docs/Learn_web_development/Getting_started/Your_first_website', true, false, false, 20,
   'Unidade 1 — Planejamento. O que é preciso para criar um site e como planejar o conteúdo antes de programar.'),
  ('desenvolvimento_web', 2, 'HTML básico', 'MDN Web Docs',
   'https://developer.mozilla.org/pt-BR/docs/Learn_web_development/Getting_started/Your_first_website/Creating_the_content', true, false, false, 30,
   'Unidade 2 — HTML. Estrutura de uma página: títulos, parágrafos, listas, links e imagens.'),
  ('desenvolvimento_web', 3, 'CSS básico', 'MDN Web Docs',
   'https://developer.mozilla.org/pt-BR/docs/Learn_web_development/Getting_started/Your_first_website/Styling_the_content', true, false, false, 30,
   'Unidade 3 — CSS. Cores, fontes e espaçamentos para deixar a página com a cara do seu projeto.'),
  ('desenvolvimento_web', 4, 'Curso HTML5 e CSS3 — Módulo 1', 'Curso em Vídeo',
   'https://www.youtube.com/playlist?list=PLHz_AreHm4dkZ9-atkcmcBaMZdmLHft8n', true, true, true, 60,
   'Unidade 4 — Prática. Aulas em vídeo do Prof. Gustavo Guanabara para fixar HTML e CSS com exercícios; certificado pelo site do Curso em Vídeo.')
on conflict (trilha_id, numero) do update set
  titulo = excluded.titulo, fonte = excluded.fonte, url = excluded.url,
  gratis = excluded.gratis, certificado = excluded.certificado,
  video = excluded.video, minutos = excluded.minutos, ementa = excluded.ementa;

-- Aulas a mais de uma versão anterior deste arquivo (se o número diminuiu)
delete from public.aulas a
 using public.trilhas t
 where a.trilha_id = t.id and a.numero > t.total_aulas
   and t.id in ('fundamentos_informatica', 'produtividade_digital', 'ferramentas_google', 'hardware', 'desenvolvimento_web');

-- 4. Conteúdos relacionados ("Continue nesta trilha"): troca todos
delete from public.conteudos_relacionados c
 using public.aulas a
 where c.aula_id = a.id
   and a.trilha_id in ('fundamentos_informatica', 'produtividade_digital', 'ferramentas_google', 'hardware', 'desenvolvimento_web');

insert into public.conteudos_relacionados (aula_id, titulo, subtitulo, tipo, url, ordem)
select a.id, r.titulo, r.subtitulo, r.tipo, r.url, r.ordem
  from (values
  ('fundamentos_informatica', 1, 1, 'Curso de Hardware — Curso em Vídeo', 'YouTube · playlist', 'video',
   'https://www.youtube.com/playlist?list=PLHz_AreHm4dn1JHgN9wpbIUhzZmycYQXW'),
  ('fundamentos_informatica', 2, 1, 'Curso de Redes — Curso em Vídeo', 'YouTube · playlist', 'video',
   'https://www.youtube.com/playlist?list=PLHz_AreHm4dkd4lr9G0Up-W-YaHYdTDuP'),
  ('fundamentos_informatica', 2, 2, 'Lidando com arquivos', 'Site · MDN', 'site',
   'https://developer.mozilla.org/pt-BR/docs/Learn_web_development/Getting_started/Environment_setup/Dealing_with_files'),
  ('fundamentos_informatica', 3, 1, 'Internet Segura para crianças e adolescentes', 'Site · CGI.br', 'site',
   'https://internetsegura.br/criancas/'),
  ('fundamentos_informatica', 3, 2, 'Fascículos da Cartilha de Segurança', 'Site · CERT.br', 'site',
   'https://cartilha.cert.br/fasciculos/'),
  ('produtividade_digital', 1, 1, 'Treinamento do Google Drive', 'Site · Google', 'site',
   'https://support.google.com/a/users/answer/9282958?hl=pt-BR'),
  ('produtividade_digital', 2, 1, 'Treinamento do Google Documentos', 'Site · Google', 'site',
   'https://support.google.com/a/users/answer/9282664?hl=pt-BR'),
  ('produtividade_digital', 3, 1, 'Treinamento do Google Planilhas', 'Site · Google', 'site',
   'https://support.google.com/a/users/answer/9282959?hl=pt-BR'),
  ('produtividade_digital', 3, 2, 'Treinamento do Google Apresentações', 'Site · Google', 'site',
   'https://support.google.com/a/users/answer/9282488?hl=pt-BR'),
  ('ferramentas_google', 1, 1, 'Treinamento do Google Agenda', 'Site · Google', 'site',
   'https://support.google.com/a/users/answer/9247501?hl=pt-BR'),
  ('ferramentas_google', 3, 1, 'Treinamento do Google Apresentações', 'Site · Google', 'site',
   'https://support.google.com/a/users/answer/9282488?hl=pt-BR'),
  ('ferramentas_google', 4, 1, 'Treinamento do Google Formulários', 'Site · Google', 'site',
   'https://support.google.com/a/users/answer/9282666?hl=pt-BR'),
  ('ferramentas_google', 4, 2, 'Treinamento do Google Meet', 'Site · Google', 'site',
   'https://support.google.com/a/users/answer/9282720?hl=pt-BR'),
  ('hardware', 1, 1, 'Noções de Hardware', 'Curso · 3h · com certificado', 'curso',
   'https://cursa.app/pt/curso-gratuito/nocoes-de-hardware-bbaf'),
  ('hardware', 1, 2, 'Clube do Hardware', 'Site', 'site',
   'https://www.clubedohardware.com.br/'),
  ('hardware', 3, 1, 'Como a web funciona', 'Site · MDN', 'site',
   'https://developer.mozilla.org/pt-BR/docs/Learn_web_development/Getting_started/Web_standards/How_the_web_works'),
  ('desenvolvimento_web', 1, 1, 'Instalando os programas básicos', 'Site · MDN', 'site',
   'https://developer.mozilla.org/pt-BR/docs/Learn_web_development/Getting_started/Environment_setup/Installing_software'),
  ('desenvolvimento_web', 2, 1, 'Curso HTML5 e CSS3 — Módulo 1', 'YouTube · playlist', 'video',
   'https://www.youtube.com/playlist?list=PLHz_AreHm4dkZ9-atkcmcBaMZdmLHft8n'),
  ('desenvolvimento_web', 3, 1, 'Design responsivo (freeCodeCamp)', 'Curso · com certificado', 'curso',
   'https://www.freecodecamp.org/portuguese/learn/2022/responsive-web-design/'),
  ('desenvolvimento_web', 4, 1, 'Publicando seu site', 'Site · MDN', 'site',
   'https://developer.mozilla.org/pt-BR/docs/Learn_web_development/Getting_started/Your_first_website/Publishing_your_website'),
  ('desenvolvimento_web', 4, 2, 'Curso de Algoritmos — Curso em Vídeo', 'YouTube · playlist', 'video',
   'https://www.youtube.com/playlist?list=PLHz_AreHm4dmSj0MHol_aoNYCSGFqvfXV')
) as r (trilha_id, aula_numero, ordem, titulo, subtitulo, tipo, url)
  join public.aulas a on a.trilha_id = r.trilha_id and a.numero = r.aula_numero;

commit;

-- 5. Conferência: uma linha por trilha com quantas aulas e conteúdos entraram
select t.ordem, t.titulo,
       count(distinct a.id) || ' de ' || t.total_aulas as aulas,
       count(c.id) as conteudos_extras
  from public.trilhas t
  left join public.aulas a on a.trilha_id = t.id
  left join public.conteudos_relacionados c on c.aula_id = a.id
 group by t.id, t.ordem, t.titulo, t.total_aulas
 order by t.ordem;
