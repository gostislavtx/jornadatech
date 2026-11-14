import 'catalog.dart';

/// Trilhas, progresso e favoritos do aluno logado.
///
/// Duas implementações: [MockCatalogRepository] (dados de exemplo em memória)
/// e `SupabaseCatalogRepository` (banco de verdade).
abstract class CatalogRepository {
  /// Instância usada pelo app. O `main.dart` troca pelo Supabase.
  static CatalogRepository shared = MockCatalogRepository();

  /// Trilhas do catálogo, já com o progresso do aluno.
  Future<List<Trilha>> trilhas();

  /// Ids das trilhas favoritas do aluno.
  Future<Set<String>> favoritos();

  Future<void> setFavorito(String trilhaId, bool favorito);

  /// Grava "não visto / visto / concluído" de uma aula.
  Future<void> setLessonStatus(Lesson lesson, LessonStatus status);
}

/// Dados de exemplo em memória (testes e `--dart-define=USE_MOCK=true`).
class MockCatalogRepository implements CatalogRepository {
  MockCatalogRepository([List<Trilha> trilhas = demoTrilhas])
      : _trilhas = trilhas;

  final List<Trilha> _trilhas;
  final Set<String> _favoritos = {};

  @override
  Future<List<Trilha>> trilhas() async => _trilhas;

  @override
  Future<Set<String>> favoritos() async => {..._favoritos};

  @override
  Future<void> setFavorito(String trilhaId, bool favorito) async {
    favorito ? _favoritos.add(trilhaId) : _favoritos.remove(trilhaId);
  }

  @override
  Future<void> setLessonStatus(Lesson lesson, LessonStatus status) async {}
}
