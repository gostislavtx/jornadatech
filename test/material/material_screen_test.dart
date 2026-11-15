import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jornadatech/data/catalog.dart';
import 'package:jornadatech/data/catalog_repository.dart';
import 'package:jornadatech/material/material_screen.dart';

Lesson _aula(int n, String title, LessonStatus status) => Lesson(
      number: n,
      title: title,
      source: 'YouTube',
      isFree: true,
      hasCertificate: false,
      minutes: 10,
      syllabus: 'Unidade $n',
      related: const [],
      status: status,
    );

void main() {
  final aula1 = _aula(1, 'Variáveis', LessonStatus.concluido);
  final aula2 = _aula(2, 'Condicionais', LessonStatus.naoVisto);
  final trilha = Trilha(
    id: 'teste',
    origin: 'Metamorfose · Módulo 1',
    title: 'Trilha de teste',
    done: 1,
    total: 2,
    tags: const {},
    currentLesson: aula2,
    lessons: [aula1, aula2],
  );

  testWidgets('abre na aula atual e troca pela lista de aulas',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: MaterialScreen(trilha: trilha, catalog: MockCatalogRepository()),
    ));

    expect(find.text('Aula 2 de 2'), findsOneWidget);
    expect(find.text('Condicionais'), findsOneWidget);
    expect(find.text('Aula 1 · Variáveis'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('aula-1')));
    await tester.tap(find.byKey(const ValueKey('aula-1')));
    await tester.pumpAndSettle();

    expect(find.text('Aula 1 de 2'), findsOneWidget);
    expect(find.text('Variáveis'), findsOneWidget);
  });

  testWidgets('aula sem link avisa em vez de abrir', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: MaterialScreen(trilha: trilha, catalog: MockCatalogRepository()),
    ));
    await tester.tap(find.byKey(const ValueKey('play')));
    await tester.pump();

    expect(find.text('O link deste conteúdo ainda não foi cadastrado.'),
        findsOneWidget);
  });
}
