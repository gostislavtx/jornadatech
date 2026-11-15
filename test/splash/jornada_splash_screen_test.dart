import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jornadatech/splash/jornada_splash_screen.dart';

Widget _host(
  Widget child, {
  bool disableAnimations = false,
  double textScale = 1,
}) {
  return MaterialApp(
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: disableAnimations,
          textScaler: TextScaler.linear(textScale),
        ),
        child: child,
      ),
    ),
  );
}

/// Simula uma tela de [width] × [height] dp.
void _useScreen(WidgetTester tester, double width, double height) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  // O splash tem animações contínuas, então os testes avançam o tempo com
  // pump(Duration) em vez de pumpAndSettle.

  testWidgets('mostra logo, etiqueta, nome, frase e carregamento',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_host(const JornadaSplashScreen()));
    await tester.pump(const Duration(seconds: 2));

    expect(find.bySemanticsLabel('Logo JornadaTech'), findsOneWidget);
    expect(find.text('CESUCA · METAMORFOSE'), findsOneWidget);
    expect(find.text('JornadaTech'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
          'Do aprendizado das aulas ao conteúdo aberto gratuito.'),
      findsOneWidget,
    );
    expect(find.text('Preparando suas trilhas'), findsOneWidget);

    // Espera o tempo mínimo (4 s) terminar.
    await tester.pump(const Duration(seconds: 3));
    semantics.dispose();
  });

  testWidgets('o logo continua se movendo depois da entrada', (tester) async {
    await tester.pumpWidget(_host(const JornadaSplashScreen(
      minDuration: Duration(seconds: 10),
    )));
    await tester.pump(const Duration(milliseconds: 2000));
    final before = tester.getCenter(find.byType(JornadaLogo));
    await tester.pump(const Duration(milliseconds: 700));
    final after = tester.getCenter(find.byType(JornadaLogo));

    expect(after.dy, isNot(moreOrLessEquals(before.dy, epsilon: 0.1)));
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('as reticências de "Preparando suas trilhas" mudam',
      (tester) async {
    await tester.pumpWidget(_host(const JornadaSplashScreen(
      minDuration: Duration(seconds: 10),
    )));
    // Os pontos mudam a cada 400 ms (6 s / 15). Lê no meio de um passo
    // (2,2 s e 2,6 s), não na virada, para o teste não depender de
    // arredondamento.
    await tester.pump(const Duration(milliseconds: 2200));
    final dots = find.byKey(const ValueKey('loading-dots'));
    final first = tester.widget<Text>(dots).data;
    await tester.pump(const Duration(milliseconds: 400));
    final second = tester.widget<Text>(dots).data;

    expect(second, isNot(first));
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('chama onFinished só depois do tempo mínimo', (tester) async {
    var finished = 0;
    await tester.pumpWidget(_host(JornadaSplashScreen(
      minDuration: const Duration(milliseconds: 2000),
      onFinished: () => finished++,
    )));

    await tester.pump(const Duration(milliseconds: 1900));
    expect(finished, 0);

    await tester.pump(const Duration(milliseconds: 200));
    expect(finished, 1);
  });

  testWidgets('espera a inicialização terminar antes de chamar onFinished',
      (tester) async {
    final loading = Completer<void>();
    var finished = 0;
    await tester.pumpWidget(_host(JornadaSplashScreen(
      minDuration: const Duration(milliseconds: 500),
      initialize: () => loading.future,
      onFinished: () => finished++,
    )));

    await tester.pump(const Duration(seconds: 2));
    expect(finished, 0);

    loading.complete();
    await tester.pump();
    expect(finished, 1);
  });

  testWidgets('com "reduzir movimento" tudo aparece parado e completo',
      (tester) async {
    await tester.pumpWidget(_host(
      const JornadaSplashScreen(minDuration: Duration(seconds: 10)),
      disableAnimations: true,
    ));
    await tester.pump();

    final fade = tester.widget<FadeTransition>(find
        .ancestor(
          of: find.text('JornadaTech'),
          matching: find.byType(FadeTransition),
        )
        .first);
    expect(fade.opacity.value, 1.0);

    final logoBefore = tester.getCenter(find.byType(JornadaLogo));
    await tester.pump(const Duration(milliseconds: 700));
    final logoAfter = tester.getCenter(find.byType(JornadaLogo));
    expect(logoAfter, logoBefore);

    await tester.pump(const Duration(seconds: 10));
  });

  // Layout: não pode estourar em celular pequeno, paisagem ou fonte grande.
  for (final (name, w, h, scale) in [
    ('tela pequena 320×480', 320.0, 480.0, 1.0),
    ('paisagem 844×390', 844.0, 390.0, 1.0),
    ('fonte em 200 %', 390.0, 844.0, 2.0),
  ]) {
    testWidgets('cabe em $name', (tester) async {
      _useScreen(tester, w, h);
      await tester.pumpWidget(
        _host(const JornadaSplashScreen(), textScale: scale),
      );
      await tester.pump(const Duration(seconds: 5));
      expect(tester.takeException(), isNull);
    });
  }

  // Logo: barras e circuito são desenhados em código e ficam animados.
  testWidgets('o logo desenha barras e circuito numa camada própria',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: JornadaLogo())),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const ValueKey('logo-art')), findsOneWidget);
  });

  testWidgets('o circuito do logo continua animando depois da montagem',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: JornadaLogo())),
    );
    await tester.pump(const Duration(seconds: 5));
    expect(tester.binding.transientCallbackCount, greaterThan(0));
  });

  testWidgets('logo com animate: false fica parado', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: JornadaLogo(animate: false))),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.transientCallbackCount, 0);
  });
}
