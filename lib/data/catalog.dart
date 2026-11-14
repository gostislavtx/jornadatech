import 'package:flutter/material.dart';

/// Filtros da home (Figma "Filtro").
enum TrilhaFilter {
  gratis('Grátis'),
  certificado('Com certificado'),
  video('Vídeo'),
  offline('Offline');

  const TrilhaFilter(this.label);
  final String label;
}

/// Situação de uma aula para o aluno ("Meu progresso").
enum LessonStatus {
  naoVisto('Não visto', Icons.radio_button_unchecked, 'nao_visto'),
  visto('Visto', Icons.visibility_outlined, 'visto'),
  concluido('Concluído', Icons.check_rounded, 'concluido');

  const LessonStatus(this.label, this.icon, this.dbValue);
  final String label;
  final IconData icon;

  /// Valor gravado na coluna `progresso.status` do banco.
  final String dbValue;

  static LessonStatus fromDb(String? value) => LessonStatus.values
      .firstWhere((s) => s.dbValue == value, orElse: () => naoVisto);
}

/// Conteúdo extra em "Continue nesta trilha".
class RelatedItem {
  const RelatedItem(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final IconData icon;
}

/// Aula/material aberto na tela "Material da trilha".
class Lesson {
  const Lesson({
    required this.number,
    required this.title,
    required this.source,
    required this.isFree,
    required this.hasCertificate,
    required this.minutes,
    required this.syllabus,
    required this.related,
    this.isVideo = true,
    this.id,
    this.status = LessonStatus.naoVisto,
  });

  /// Id da aula no banco (`aulas.id`); `null` nos dados de exemplo.
  final String? id;

  /// Situação desta aula para o aluno logado.
  final LessonStatus status;

  final int number;
  final String title;

  /// Plataforma de origem ("YouTube", "MDN Web Docs"…).
  final String source;
  final bool isFree;
  final bool hasCertificate;
  final int minutes;
  final bool isVideo;

  /// Texto do bloco "Cobre da ementa".
  final String syllabus;
  final List<RelatedItem> related;
}

class Trilha {
  const Trilha({
    required this.id,
    required this.origin,
    required this.title,
    required this.done,
    required this.total,
    required this.tags,
    required this.currentLesson,
  });

  final String id;

  /// Sobretítulo do card ("Metamorfose · Módulo 2").
  final String origin;
  final String title;
  final int done;
  final int total;
  final Set<TrilhaFilter> tags;
  final Lesson currentLesson;

  double get progress => total == 0 ? 0 : done / total;
  int get percent => (progress * 100).round();
}

/// MOCK: trilhas de exemplo do protótipo. A de Banco de Dados usa o conteúdo
/// do Figma; as outras duas seguem o mesmo formato.
const demoTrilhas = <Trilha>[
  Trilha(
    id: 'logica',
    origin: 'Metamorfose · Módulo 2',
    title: 'Lógica de Programação',
    done: 9,
    total: 12,
    tags: {TrilhaFilter.gratis, TrilhaFilter.video, TrilhaFilter.offline},
    currentLesson: Lesson(
      number: 10,
      title: 'Laços de repetição: for e while na prática',
      source: 'YouTube',
      isFree: true,
      hasCertificate: false,
      minutes: 24,
      syllabus: 'Unidade 4 — Estruturas de repetição. Reforça o que foi '
          'visto em aula com exercícios resolvidos passo a passo.',
      related: [
        RelatedItem('Beecrowd — exercícios iniciantes', 'Site',
            Icons.language_rounded),
        RelatedItem('Curso Lógica com Python', 'Curso · 20h · com certificado',
            Icons.school_outlined),
        RelatedItem('Algoritmos explicados (playlist)', 'YouTube · 1h10',
            Icons.play_circle_outline_rounded),
      ],
    ),
  ),
  Trilha(
    id: 'bd-sql',
    origin: 'Cesuca · Fundamentos de BD',
    title: 'Banco de Dados & SQL',
    done: 4,
    total: 11,
    tags: {TrilhaFilter.gratis, TrilhaFilter.video},
    currentLesson: Lesson(
      number: 5,
      title: 'Consultas com JOIN: unindo tabelas na prática',
      source: 'YouTube',
      isFree: true,
      hasCertificate: false,
      minutes: 32,
      syllabus: 'Unidade 3 — Álgebra relacional e consultas multi-tabela. '
          'Aprofunda o que foi visto em aula com exemplos reais e exercícios.',
      related: [
        RelatedItem('SQL Zoo — exercícios guiados', 'Site',
            Icons.language_rounded),
        RelatedItem('Curso Modelagem Relacional',
            'Curso · 12h · com certificado', Icons.school_outlined),
        RelatedItem('JOINs na prática (playlist)', 'YouTube · 48min',
            Icons.play_circle_outline_rounded),
      ],
    ),
  ),
  Trilha(
    id: 'front-end',
    origin: 'Metamorfose · Módulo 4',
    title: 'Front-end com HTML e CSS',
    done: 0,
    total: 10,
    tags: {TrilhaFilter.certificado, TrilhaFilter.video},
    currentLesson: Lesson(
      number: 1,
      title: 'Sua primeira página com HTML semântico',
      source: 'MDN Web Docs',
      isFree: true,
      hasCertificate: true,
      minutes: 40,
      isVideo: false,
      syllabus: 'Unidade 1 — Estrutura de documentos HTML. Base para os '
          'exercícios de layout das próximas aulas.',
      related: [
        RelatedItem('Guia de CSS Flexbox', 'Site', Icons.language_rounded),
        RelatedItem('Curso Responsive Web Design',
            'Curso · 300h · com certificado', Icons.school_outlined),
        RelatedItem('HTML e CSS do zero (playlist)', 'YouTube · 2h',
            Icons.play_circle_outline_rounded),
      ],
    ),
  ),
];
