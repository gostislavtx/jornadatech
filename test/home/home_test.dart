import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jornadatech/data/auth_repository.dart';
import 'package:jornadatech/data/catalog_repository.dart';
import 'package:jornadatech/home/home_shell.dart';

const _ana = AppUser(username: 'CorujaAzul42');

Future<void> _pumpHome(WidgetTester tester, {VoidCallback? onLogout}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: HomeShell(
        user: _ana,
        catalog: MockCatalogRepository(),
        onLogout: onLogout,
      ),
    ),
  );
  await tester.pump(); // carrega as trilhas do repositório
}

void main() {
  testWidgets('saúda pelo nome e lista as trilhas com progresso',
      (tester) async {
    await _pumpHome(tester);

    expect(find.text('Bom estudo,'), findsOneWidget);
    expect(find.text('CorujaAzul42'), findsOneWidget);
    expect(find.text('Lógica de Programação'), findsOneWidget);
    expect(find.text('9 de 12 aulas'), findsOneWidget);
    expect(find.text('75% concluído'), findsOneWidget);
  });

  testWidgets('a busca ignora acentos', (tester) async {
    await _pumpHome(tester);
    await tester.enterText(find.byKey(const ValueKey('search')), 'logica');
    await tester.pump();

    expect(find.text('Lógica de Programação'), findsOneWidget);
    expect(find.text('Banco de Dados & SQL'), findsNothing);
  });

  testWidgets('filtro "Com certificado" deixa só o Front-end',
      (tester) async {
    await _pumpHome(tester);
    await tester.tap(find.byTooltip('Mostrar filtros'));
    await tester.pump();
    expect(find.text('Filtros'), findsOneWidget);

    await tester.tap(find.text('Com certificado'));
    await tester.pump();
    expect(find.text('Front-end com HTML e CSS'), findsOneWidget);
    expect(find.text('Lógica de Programação'), findsNothing);

    await tester.tap(find.text('Todos'));
    await tester.pump();
    expect(find.text('Lógica de Programação'), findsOneWidget);
  });

  testWidgets('favoritar troca a estrela', (tester) async {
    await _pumpHome(tester);
    final fav = find.byKey(const ValueKey('fav-logica'));
    expect(
        find.descendant(of: fav, matching: find.byIcon(Icons.star_rounded)),
        findsNothing);

    await tester.tap(fav);
    await tester.pumpAndSettle();
    expect(
        find.descendant(of: fav, matching: find.byIcon(Icons.star_rounded)),
        findsOneWidget);
  });

  testWidgets('tocar no card abre o material da trilha', (tester) async {
    await _pumpHome(tester);
    await tester.tap(find.text('Banco de Dados & SQL'));
    await tester.pumpAndSettle();

    expect(find.text('Consultas com JOIN: unindo tabelas na prática'),
        findsOneWidget);
    expect(find.text('Aula 5 de 11'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('status-concluido')));
    await tester.tap(find.byKey(const ValueKey('status-concluido')));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('aba Ajuda e menu Sair', (tester) async {
    var loggedOut = false;
    await _pumpHome(tester, onLogout: () => loggedOut = true);

    await tester.tap(find.text('Ajuda'));
    await tester.pumpAndSettle();
    expect(find.text('Suporte para você,'), findsOneWidget);
    expect(find.text('Tutorial de Uso'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('menu-button')).hitTestable());
    await tester.pumpAndSettle();
    expect(find.text('Perfil'), findsOneWidget);

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();
    expect(loggedOut, isTrue);
  });
}
