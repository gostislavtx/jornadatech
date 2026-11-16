-- =============================================================================
-- JornadaTech · conteúdo das 5 trilhas
-- Trilhas: Leonardo · Curadoria das aulas e conteúdos: Giovane (15/11/2026)
--
-- Como usar: Supabase → SQL Editor → colar este arquivo inteiro → Run.
-- Pode rodar quantas vezes quiser: atualiza pela chave (trilha, número da
-- aula) e não duplica. Os mesmos dados estão em conteudo/*.csv.
-- =============================================================================

begin;

-- 1. Tira as 3 trilhas de exemplo do seed.sql (aulas e progresso delas saem junto)
delete from public.trilhas where id in ('logica', 'bd-sql', 'front-end');

-- 2. Trilhas
insert into public.trilhas (id, origem, titulo, total_aulas, gratis, certificado, video, offline, ordem) values
  ('fundamentos_informatica', 'Projeto Metamorfose', 'Fundamentos da Informática', 7, true, true, true, true, 1),
  ('produtividade_digital', 'Projeto Metamorfose', 'Produtividade Digital', 6, true, true, true, false, 2),
  ('ferramentas_google', 'Projeto Metamorfose', 'Ferramentas Google', 7, true, false, false, false, 3),
  ('hardware', 'Projeto Metamorfose', 'Hardware e Arquitetura de Computadores', 5, true, true, true, true, 4),
  ('desenvolvimento_web', 'Projeto Metamorfose', 'Introdução ao Desenvolvimento Web', 7, true, true, true, true, 5)
on conflict (id) do update set
  origem = excluded.origem, titulo = excluded.titulo,
  total_aulas = excluded.total_aulas, gratis = excluded.gratis,
  certificado = excluded.certificado, video = excluded.video,
  offline = excluded.offline, ordem = excluded.ordem;

-- 3. Aulas
insert into public.aulas (trilha_id, numero, titulo, fonte, url, gratis, certificado, video, minutos, ementa) values
  ('fundamentos_informatica', 1, 'O que é hardware e o que é software', 'GCFGlobal',
   'https://edu.gcfglobal.org/pt/informatica-basica/o-que-sao-hardware-e-software-/1/', true, false, false, 10,
   'Unidade 1 — O computador e seus componentes. Diferencia a parte física (hardware) da parte lógica (software) com exemplos do dia a dia.'),
  ('fundamentos_informatica', 2, 'Sistema operacional: o que é e para que serve', 'GCFGlobal',
   'https://edu.gcfglobal.org/pt/informatica-basica/o-que-e-um-sistema-operacional/1/', true, false, false, 10,
   'Unidade 2 — Sistemas operacionais. Mostra o papel do Windows, Linux, Android e iOS como gerentes do computador e do celular.'),
  ('fundamentos_informatica', 3, 'Contas de usuário no Windows', 'GCFGlobal',
   'https://edu.gcfglobal.org/pt/tudo-sobre-o-windows-10/como-incluir-uma-conta-de-usuario/1/', true, false, false, 10,
   'Unidade 2 — Uso do Windows. Pratica a criação de contas e explica a diferença entre administrador e usuário padrão.'),
  ('fundamentos_informatica', 4, 'Golpes na internet: não se deixe enganar', 'CERT.br',
   'https://cartilha.cert.br/fasciculos/#golpes', true, false, false, 15,
   'Unidade 3 — Internet e segurança. Ensina a reconhecer golpes por mensagem, Pix, sites falsos e perfis falsos.'),
  ('fundamentos_informatica', 5, 'Senhas fortes e verificação em duas etapas', 'CERT.br',
   'https://cartilha.cert.br/fasciculos/#autenticacao', true, false, false, 10,
   'Unidade 3 — Internet e segurança. Aprofunda como criar senhas seguras e ativar a verificação em duas etapas nas contas.'),
  ('fundamentos_informatica', 6, 'Protegendo seus dados pessoais', 'CERT.br',
   'https://cartilha.cert.br/fasciculos/#protecao-de-dados', true, false, false, 10,
   'Unidade 3 — Internet e segurança. Explica o que são dados pessoais, como reduzir a exposição e os direitos garantidos pela LGPD.'),
  ('fundamentos_informatica', 7, 'Cultura digital: redes sociais e pacote Office', 'Fundação Bradesco · Escola Virtual',
   'https://www.ev.org.br/cursos/cultura-digital', true, true, false, 360,
   'Revisão da trilha — Fecha o módulo com uso consciente das redes sociais e uma visão geral do pacote Office, com certificado gratuito.'),
  ('produtividade_digital', 1, 'Guardando arquivos na nuvem com o OneDrive', 'Fundação Bradesco · Escola Virtual',
   'https://www.ev.org.br/cursos/microsoft-office-365-conhecendo-o-onedrive', true, true, true, 60,
   'Unidade 1 — Arquivos e nuvem. Mostra como salvar, organizar e compartilhar arquivos online para acessar de qualquer lugar.'),
  ('produtividade_digital', 2, 'Editor de textos: Word básico', 'Fundação Bradesco · Escola Virtual',
   'https://www.ev.org.br/cursos/microsoft-word-2016-basico', true, true, false, 540,
   'Unidade 2 — Editor de textos. Pratica salvar, formatar, revisar e imprimir documentos como currículos e trabalhos.'),
  ('produtividade_digital', 3, 'Planilhas: Excel básico', 'Fundação Bradesco · Escola Virtual',
   'https://www.ev.org.br/cursos/microsoft-excel-2016-basico', true, true, false, 900,
   'Unidade 3 — Planilhas eletrônicas. Ensina formatação, fórmulas, funções e gráficos para organizar dados e contas da casa.'),
  ('produtividade_digital', 4, 'Apresentações: PowerPoint básico', 'Fundação Bradesco · Escola Virtual',
   'https://www.ev.org.br/cursos/microsoft-powerpoint-2016-basico', true, true, false, 480,
   'Unidade 4 — Apresentações. Ensina a montar slides com imagens, animações e transições para apresentar trabalhos.'),
  ('produtividade_digital', 5, 'E-mail profissional com o Outlook', 'Fundação Bradesco · Escola Virtual',
   'https://www.ev.org.br/cursos/microsoft-office-365-conhecendo-o-outlook', true, true, true, 60,
   'Unidade 5 — Comunicação digital. Mostra como enviar, organizar e responder e-mails de forma profissional.'),
  ('produtividade_digital', 6, 'Organizando tarefas em equipe com o Planner', 'Fundação Bradesco · Escola Virtual',
   'https://www.ev.org.br/cursos/microsoft-office-365-conhecendo-o-planner', true, true, true, 60,
   'Unidade 6 — Organização e trabalho em equipe. Ensina a dividir tarefas, definir prazos e acompanhar o andamento.'),
  ('ferramentas_google', 1, 'Gmail: enviar, organizar e encontrar e-mails', 'Google Workspace · Centro de aprendizagem',
   'https://support.google.com/a/users/answer/9259748?hl=pt-BR', true, false, false, 30,
   'Unidade 1 — Comunicação com Gmail. Pratica escrever, responder, anexar arquivos e organizar a caixa de entrada com marcadores.'),
  ('ferramentas_google', 2, 'Google Drive: guardar e compartilhar arquivos', 'Google Workspace · Centro de aprendizagem',
   'https://support.google.com/a/users/answer/9282958?hl=pt-BR', true, false, false, 25,
   'Unidade 2 — Armazenamento na nuvem. Mostra como enviar, organizar em pastas e compartilhar arquivos com permissões.'),
  ('ferramentas_google', 3, 'Documentos Google: escrever e editar em grupo', 'Google Workspace · Centro de aprendizagem',
   'https://support.google.com/a/users/answer/9282664?hl=pt-BR', true, false, false, 30,
   'Unidade 3 — Documentos Google. Ensina a criar, formatar e editar textos em conjunto, com comentários e histórico de versões.'),
  ('ferramentas_google', 4, 'Planilhas Google: organizar dados e fazer contas', 'Google Workspace · Centro de aprendizagem',
   'https://support.google.com/a/users/answer/9282959?hl=pt-BR', true, false, false, 30,
   'Unidade 4 — Planilhas Google. Aprofunda fórmulas básicas, filtros e gráficos para organizar informações.'),
  ('ferramentas_google', 5, 'Apresentações Google: criar e apresentar slides', 'Google Workspace · Centro de aprendizagem',
   'https://support.google.com/a/users/answer/9282488?hl=pt-BR', true, false, false, 25,
   'Unidade 5 — Apresentações Google. Ensina a criar, compartilhar e apresentar slides direto do navegador.'),
  ('ferramentas_google', 6, 'Formulários Google: pesquisas, inscrições e quizzes', 'Google Workspace · Centro de aprendizagem',
   'https://support.google.com/a/users/answer/9282666?hl=pt-BR', true, false, false, 20,
   'Unidade 6 — Formulários Google. Mostra como criar formulários e quizzes e analisar as respostas em uma planilha.'),
  ('ferramentas_google', 7, 'Agenda Google e Meet: compromissos e videochamadas', 'Google Workspace · Centro de aprendizagem',
   'https://support.google.com/a/users/answer/9247501?hl=pt-BR', true, false, false, 25,
   'Unidade 7 — Organização e reuniões online. Ensina a marcar compromissos, enviar convites e entrar em videochamadas.'),
  ('hardware', 1, 'Principais componentes de um PC', 'YouTube · Welington Tutoriais',
   'https://www.youtube.com/watch?v=CGDryR8fdHo', true, false, true, 15,
   'Unidade 1 — Componentes do computador. Apresenta placa-mãe, processador, memória RAM, armazenamento e periféricos e a função de cada um.'),
  ('hardware', 2, 'Como o computador processa e guarda informações', 'Fundação Bradesco · Escola Virtual',
   'https://www.ev.org.br/cursos/fundamentos-de-ti-hardware-e-software', true, true, false, 420,
   'Unidade 2 — Arquitetura e funcionamento. Explica a evolução da computação, processamento, armazenamento e os componentes internos e externos.'),
  ('hardware', 3, 'Por dentro do computador: peças e montagem', 'Coursera · Google',
   'https://www.coursera.org/learn/fundamentos-do-suporte-tecnico', true, false, true, 180,
   'Unidade 3 — Hardware na prática. A semana 2 do curso abre o computador e mostra as peças e a montagem; dá para assistir no modo gratuito.'),
  ('hardware', 4, 'Do hardware ao sistema operacional', 'Coursera · Google',
   'https://www.coursera.org/learn/sistemas-operacionais', true, false, true, 240,
   'Unidade 4 — Software básico. Mostra como Windows e Linux gerenciam arquivos, programas e o próprio hardware (nível intermediário).'),
  ('hardware', 5, 'Cuidando do computador: segurança e prevenção', 'CERT.br',
   'https://www.gov.br/governodigital/pt-br/privacidade-e-seguranca/fasciculos-cert.br/fasciculo-computadores.pdf', true, false, false, 10,
   'Unidade 5 — Prevenção e segurança. Reúne cuidados como atualizações, antivírus, cópias de segurança e contas separadas.'),
  ('desenvolvimento_web', 1, 'Como a internet funciona', 'Curso em Vídeo (YouTube)',
   'https://www.youtube.com/watch?v=nlO5hySqJFA', true, false, true, 22,
   'Unidade 1 — Internet e web. Explica o caminho dos dados entre o seu computador e os servidores, base para entender como um site chega até você.'),
  ('desenvolvimento_web', 2, 'Front-end, back-end e full stack', 'Curso em Vídeo (YouTube)',
   'https://www.youtube.com/watch?v=iSqf2iPqJNM', true, false, true, 15,
   'Unidade 1 — Profissões da web. Diferencia quem cria a parte visual do site, quem cuida do servidor e quem faz os dois.'),
  ('desenvolvimento_web', 3, 'Instalando as ferramentas: VS Code e navegador', 'Curso em Vídeo (YouTube)',
   'https://www.youtube.com/watch?v=UForX7ehChM', true, false, true, 20,
   'Unidade 2 — Ambiente de desenvolvimento. Prepara o computador com editor de código em português e navegador para testar páginas.'),
  ('desenvolvimento_web', 4, 'Seu primeiro código HTML', 'Curso em Vídeo (YouTube)',
   'https://www.youtube.com/watch?v=E6CdIawPTh0', true, false, true, 25,
   'Unidade 2 — Primeira página. Cria do zero o primeiro arquivo HTML e abre o resultado no navegador.'),
  ('desenvolvimento_web', 5, 'Títulos e parágrafos em HTML', 'MDN Web Docs',
   'https://developer.mozilla.org/pt-BR/docs/Learn_web_development/Core/Structuring_content/Headings_and_paragraphs', true, false, false, 30,
   'Unidade 3 — Estrutura do conteúdo. Aprofunda a hierarquia de títulos (h1 a h6) e os parágrafos para páginas organizadas e acessíveis.'),
  ('desenvolvimento_web', 6, 'Listas em HTML', 'Curso em Vídeo (YouTube)',
   'https://www.youtube.com/watch?v=JlE0pzESf5g', true, false, true, 13,
   'Unidade 3 — Listas. Pratica listas numeradas e com marcadores para organizar informações na página.'),
  ('desenvolvimento_web', 7, 'HTML5 e CSS3: Módulo 1 completo', 'Curso em Vídeo',
   'https://www.cursoemvideo.com/curso/html5-css3-modulo1/', true, true, true, 2400,
   'Revisão da trilha — Reúne todas as aulas do módulo 1 com exercícios e certificado gratuito ao concluir pelo site.')
on conflict (trilha_id, numero) do update set
  titulo = excluded.titulo, fonte = excluded.fonte, url = excluded.url,
  gratis = excluded.gratis, certificado = excluded.certificado,
  video = excluded.video, minutos = excluded.minutos, ementa = excluded.ementa;

-- Aulas que sobraram de uma versão anterior (se uma trilha ficou menor)
delete from public.aulas a
 using public.trilhas t
 where a.trilha_id = t.id and a.numero > t.total_aulas
   and t.id in ('fundamentos_informatica', 'produtividade_digital', 'ferramentas_google', 'hardware', 'desenvolvimento_web');

-- 4. Conteúdos relacionados ("Continue nesta trilha"): troca todos
delete from public.conteudos_relacionados c
 using public.aulas a
 where c.aula_id = a.id and a.trilha_id in ('fundamentos_informatica', 'produtividade_digital', 'ferramentas_google', 'hardware', 'desenvolvimento_web');

insert into public.conteudos_relacionados (aula_id, titulo, subtitulo, tipo, url, ordem)
select a.id, r.titulo, r.subtitulo, r.tipo, r.url, r.ordem
  from (values
  ('fundamentos_informatica', 1, 1, 'Fundamentos de TI: Hardware e Software', 'Curso · 7h · com certificado', 'curso',
   'https://www.ev.org.br/cursos/fundamentos-de-ti-hardware-e-software'),
  ('fundamentos_informatica', 1, 2, 'Principais componentes de um PC', 'YouTube · Welington Tutoriais', 'video',
   'https://www.youtube.com/watch?v=CGDryR8fdHo'),
  ('fundamentos_informatica', 2, 1, 'Fundamentos de TI: Hardware e Software', 'Curso · 7h · com certificado', 'curso',
   'https://www.ev.org.br/cursos/fundamentos-de-ti-hardware-e-software'),
  ('fundamentos_informatica', 3, 1, 'Cuidados com o computador', 'Site · PDF do CERT.br', 'site',
   'https://www.gov.br/governodigital/pt-br/privacidade-e-seguranca/fasciculos-cert.br/fasciculo-computadores.pdf'),
  ('fundamentos_informatica', 4, 1, 'Golpes: caiu? Veja o que fazer', 'Site · CERT.br', 'site',
   'https://cartilha.cert.br/fasciculos/#golpes-o-que-fazer'),
  ('fundamentos_informatica', 4, 2, 'Phishing e outros golpes', 'Site · CERT.br', 'site',
   'https://cartilha.cert.br/fasciculos/#phishing-golpes'),
  ('fundamentos_informatica', 4, 3, 'Internet Segura', 'Site · materiais para todas as idades', 'site',
   'https://internetsegura.br/'),
  ('fundamentos_informatica', 5, 1, 'Celulares e tablets', 'Site · CERT.br', 'site',
   'https://cartilha.cert.br/fasciculos/#celulares-e-tablets'),
  ('fundamentos_informatica', 5, 2, 'Cidadão na Rede', 'Vídeos curtos · NIC.br', 'video',
   'https://cidadaonarede.nic.br/'),
  ('fundamentos_informatica', 6, 1, 'Vazamento de dados: o que fazer', 'Site · PDF do CERT.br', 'site',
   'https://cartilha.cert.br/guardiao/fasciculo-vazamento-de-dados-egc.pdf'),
  ('fundamentos_informatica', 6, 2, 'Boatos e notícias falsas', 'Site · CERT.br', 'site',
   'https://cartilha.cert.br/fasciculos/#boatos'),
  ('fundamentos_informatica', 7, 1, 'Fundamentos de TI: Hardware e Software', 'Curso · 7h · com certificado', 'curso',
   'https://www.ev.org.br/cursos/fundamentos-de-ti-hardware-e-software'),
  ('fundamentos_informatica', 7, 2, 'Office na Prática (trilha)', 'Curso · 48h · com certificado', 'curso',
   'https://www.ev.org.br/trilhas-de-conhecimento/office-na-pratica'),
  ('produtividade_digital', 1, 1, 'Conhecendo o OneNote', 'Curso · 1h · certificado de participação', 'curso',
   'https://www.ev.org.br/cursos/microsoft-office-365-conhecendo-o-onenote'),
  ('produtividade_digital', 2, 1, 'Word na Prática', 'Curso · 16h · com certificado', 'curso',
   'https://www.ev.org.br/cursos/word-na-pratica'),
  ('produtividade_digital', 2, 2, 'Word 2016 Intermediário', 'Curso · 12h · com certificado', 'curso',
   'https://www.ev.org.br/cursos/microsoft-word-2016-intermediario'),
  ('produtividade_digital', 3, 1, 'Excel na Prática', 'Curso · 16h · com certificado', 'curso',
   'https://www.ev.org.br/cursos/excel-na-pratica'),
  ('produtividade_digital', 3, 2, 'Excel 2016 Intermediário', 'Curso · 20h · com certificado', 'curso',
   'https://www.ev.org.br/cursos/microsoft-excel-2016-intermediario'),
  ('produtividade_digital', 4, 1, 'PowerPoint na Prática', 'Curso · 16h · com certificado', 'curso',
   'https://www.ev.org.br/cursos/powerpoint-na-pratica'),
  ('produtividade_digital', 5, 1, 'Gmail: treinamento oficial', 'Site · Google', 'site',
   'https://support.google.com/a/users/answer/9259748?hl=pt-BR'),
  ('produtividade_digital', 6, 1, 'Conhecendo o Teams', 'Curso · 1h · certificado de participação', 'curso',
   'https://www.ev.org.br/cursos/microsoft-office-365-conhecendo-o-teams'),
  ('produtividade_digital', 6, 2, 'Office na Prática (trilha)', 'Curso · 48h · com certificado', 'curso',
   'https://www.ev.org.br/trilhas-de-conhecimento/office-na-pratica'),
  ('ferramentas_google', 1, 1, 'Central de Ajuda do Gmail', 'Site · Google', 'site',
   'https://support.google.com/mail/?hl=pt-BR'),
  ('ferramentas_google', 1, 2, 'Google Contatos', 'Site · Google', 'site',
   'https://support.google.com/a/users/answer/9282487?hl=pt-BR'),
  ('ferramentas_google', 2, 1, 'Apps do Google no celular', 'Site · Google', 'site',
   'https://support.google.com/a/users/answer/9282663?hl=pt-BR'),
  ('ferramentas_google', 3, 1, 'Central de Ajuda do Documentos', 'Site · Google', 'site',
   'https://support.google.com/docs/topic/9046002?hl=pt-BR'),
  ('ferramentas_google', 4, 1, 'Central de Ajuda do Planilhas', 'Site · Google', 'site',
   'https://support.google.com/docs/topic/9054603?hl=pt-BR'),
  ('ferramentas_google', 5, 1, 'Central de Ajuda do Apresentações', 'Site · Google', 'site',
   'https://support.google.com/docs/topic/9052835?hl=pt-BR'),
  ('ferramentas_google', 6, 1, 'Central de Ajuda do Formulários', 'Site · Google', 'site',
   'https://support.google.com/docs/topic/9055404?hl=pt-BR'),
  ('ferramentas_google', 7, 1, 'Google Meet', 'Site · Google', 'site',
   'https://support.google.com/a/users/answer/9282720?hl=pt-BR'),
  ('ferramentas_google', 7, 2, 'Google Tarefas', 'Site · Google', 'site',
   'https://support.google.com/a/users/answer/9991367?hl=pt-BR'),
  ('ferramentas_google', 7, 3, 'Google Keep', 'Site · Google', 'site',
   'https://support.google.com/keep/?hl=pt-BR'),
  ('hardware', 1, 1, 'O que são hardware e software', 'Site · GCFGlobal', 'site',
   'https://edu.gcfglobal.org/pt/informatica-basica/o-que-sao-hardware-e-software-/1/'),
  ('hardware', 2, 1, 'Sistema operacional: o que é', 'Site · GCFGlobal', 'site',
   'https://edu.gcfglobal.org/pt/informatica-basica/o-que-e-um-sistema-operacional/1/'),
  ('hardware', 5, 1, 'Celulares e tablets', 'Site · CERT.br', 'site',
   'https://cartilha.cert.br/fasciculos/#celulares-e-tablets'),
  ('desenvolvimento_web', 1, 1, 'O modelo de padrões da web', 'Site · MDN Web Docs', 'site',
   'https://developer.mozilla.org/pt-BR/docs/Learn_web_development/Getting_started/Web_standards/The_web_standards_model'),
  ('desenvolvimento_web', 2, 1, 'Aprendendo desenvolvimento web', 'Site · MDN Web Docs', 'site',
   'https://developer.mozilla.org/pt-BR/docs/Learn_web_development'),
  ('desenvolvimento_web', 3, 1, 'Seu primeiro site', 'Site · MDN Web Docs', 'site',
   'https://developer.mozilla.org/pt-BR/docs/Learn_web_development/Getting_started/Your_first_website'),
  ('desenvolvimento_web', 4, 1, 'Sintaxe básica do HTML', 'Site · MDN Web Docs', 'site',
   'https://developer.mozilla.org/pt-BR/docs/Learn_web_development/Core/Structuring_content/Basic_HTML_syntax'),
  ('desenvolvimento_web', 4, 2, 'Material de apoio em PDF', 'Site · GitHub do Curso em Vídeo', 'site',
   'https://github.com/gustavoguanabara/html-css/tree/master/aulas-pdf'),
  ('desenvolvimento_web', 5, 1, 'Teste suas habilidades: texto em HTML', 'Site · MDN Web Docs', 'site',
   'https://developer.mozilla.org/pt-BR/docs/Learn_web_development/Core/Structuring_content/Test_your_skills/HTML_text_basics'),
  ('desenvolvimento_web', 6, 1, 'Playlist completa do Módulo 1', 'YouTube · Curso em Vídeo', 'video',
   'https://www.youtube.com/playlist?list=PLHz_AreHm4dkZ9-atkcmcBaMZdmLHft8n'),
  ('desenvolvimento_web', 7, 1, 'freeCodeCamp: Design Web Responsivo', 'Curso · em português · com certificado', 'curso',
   'https://www.freecodecamp.org/portuguese/learn/2022/responsive-web-design/'),
  ('desenvolvimento_web', 7, 2, 'Material de apoio em PDF', 'Site · GitHub do Curso em Vídeo', 'site',
   'https://github.com/gustavoguanabara/html-css/tree/master/aulas-pdf')
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
