import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'catalog.dart';
import 'catalog_repository.dart';

/// Catálogo, progresso e favoritos no Supabase (`supabase/schema.sql`).
///
/// O banco só devolve o progresso e os favoritos do próprio aluno (RLS).
class SupabaseCatalogRepository implements CatalogRepository {
  SupabaseCatalogRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Trilha>> trilhas() async {
    final rows = await _client
        .from('trilhas')
        .select('*, aulas(*, conteudos_relacionados(*))')
        .order('ordem');
    final progresso = await _client.from('progresso').select('aula_id, status');
    final status = {
      for (final p in progresso)
        p['aula_id'] as String: LessonStatus.fromDb(p['status'] as String?),
    };

    final trilhas = <Trilha>[];
    for (final t in rows) {
      final aulas = [
        for (final a in (t['aulas'] as List).cast<Map<String, dynamic>>())
          _lesson(a, status[a['id']] ?? LessonStatus.naoVisto),
      ]..sort((a, b) => a.number.compareTo(b.number));
      if (aulas.isEmpty) continue; // trilha ainda sem conteúdo

      final done =
          aulas.where((a) => a.status == LessonStatus.concluido).length;
      // Aula atual = a primeira ainda não concluída (ou a última).
      final current = aulas.firstWhere(
        (a) => a.status != LessonStatus.concluido,
        orElse: () => aulas.last,
      );
      trilhas.add(Trilha(
        id: t['id'] as String,
        origin: t['origem'] as String,
        title: t['titulo'] as String,
        done: done,
        total: t['total_aulas'] as int,
        tags: {
          if (t['gratis'] == true) TrilhaFilter.gratis,
          if (t['certificado'] == true) TrilhaFilter.certificado,
          if (t['video'] == true) TrilhaFilter.video,
          if (t['offline'] == true) TrilhaFilter.offline,
        },
        currentLesson: current,
      ));
    }
    return trilhas;
  }

  static Lesson _lesson(Map<String, dynamic> a, LessonStatus status) {
    final related = (a['conteudos_relacionados'] as List)
        .cast<Map<String, dynamic>>()
      ..sort((x, y) => (x['ordem'] as int).compareTo(y['ordem'] as int));
    return Lesson(
      id: a['id'] as String,
      status: status,
      number: a['numero'] as int,
      title: a['titulo'] as String,
      source: a['fonte'] as String,
      isFree: a['gratis'] as bool,
      hasCertificate: a['certificado'] as bool,
      isVideo: a['video'] as bool,
      minutes: a['minutos'] as int,
      syllabus: a['ementa'] as String,
      related: [
        for (final r in related)
          RelatedItem(
            r['titulo'] as String,
            r['subtitulo'] as String,
            switch (r['tipo']) {
              'curso' => Icons.school_outlined,
              'video' => Icons.play_circle_outline_rounded,
              _ => Icons.language_rounded,
            },
          ),
      ],
    );
  }

  @override
  Future<Set<String>> favoritos() async {
    final rows = await _client.from('favoritos').select('trilha_id');
    return {for (final r in rows) r['trilha_id'] as String};
  }

  @override
  Future<void> setFavorito(String trilhaId, bool favorito) async {
    if (favorito) {
      await _client.from('favoritos').upsert({'trilha_id': trilhaId});
    } else {
      await _client.from('favoritos').delete().eq('trilha_id', trilhaId);
    }
  }

  @override
  Future<void> setLessonStatus(Lesson lesson, LessonStatus status) async {
    final id = lesson.id;
    if (id == null) return;
    await _client.from('progresso').upsert({
      'aula_id': id,
      'status': status.dbValue,
      'atualizado_em': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'usuario_id,aula_id');
  }
}
