import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jornadatech/data/auth_repository.dart';
import 'package:jornadatech/data/username_generator.dart';
import 'package:jornadatech/login/jornada_login_screen.dart';

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

/// Espera a "ida ao servidor" do mock terminar e as telas assentarem.
Future<void> _server(WidgetTester tester) async {
  await tester.pump(AuthRepository.latency + const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
}

void main() {
  group('Nome de usuário e código', () {
    test('o nome gerado é Animal + Característica + 2 dígitos', () {
      final name = UsernameGenerator(Random(1)).next();
      expect(name, matches(RegExp(r'^[A-Z][a-z]+[A-Z][a-z]+\d{2}$')));
    });

    test('o código tem o formato XXXX-XXXX sem caracteres ambíguos', () {
      final code = generateRecoveryCode(Random(1));
      expect(code, matches(RegExp(r'^[A-Z2-9]{4}-[A-Z2-9]{4}$')));
      expect(code, isNot(matches(RegExp(r'[01OIL]'))));
    });

    test('aceita o código digitado em minúsculas e sem hífen', () {
      expect(normalizeRecoveryCode(' k7m2qx9p '), 'K7M2-QX9P');
    });

    test('senha precisa de 8+ caracteres, com letras e números', () {
      expect(AuthRepository.validatePassword('abc12'), isNotNull);
      expect(AuthRepository.validatePassword('abcdefgh'), isNotNull);
      expect(AuthRepository.validatePassword('trilha2026'), isNull);
    });
  });

  group('Login', () {
    late AuthRepository auth;
    AppUser? loggedIn;

    Future<void> pumpLogin(WidgetTester tester) async {
      _phone(tester);
      auth = AuthRepository.demo(random: Random(7));
      loggedIn = null;
      await tester.pumpWidget(MaterialApp(
        home: JornadaLoginScreen(
          auth: auth,
          onLoggedIn: (u) => loggedIn = u,
        ),
      ));
    }

    testWidgets('não pede nome real, CPF nem e-mail', (tester) async {
      await pumpLogin(tester);
      expect(find.text('NOME DE USUÁRIO'), findsOneWidget);
      expect(find.text('Primeira vez aqui?'), findsOneWidget);
      expect(find.textContaining('CPF 000'), findsNothing);
      expect(find.text('NOME COMPLETO'), findsNothing);
    });

    testWidgets('senha errada mostra aviso e não entra', (tester) async {
      await pumpLogin(tester);
      await tester.enterText(find.byKey(const ValueKey('login-username')),
          AuthRepository.demoUsername);
      await tester.enterText(
          find.byKey(const ValueKey('login-password')), 'errada123');
      await _tap(tester, find.text('Acessar minhas trilhas'));
      await _server(tester);

      expect(find.text('Nome de usuário ou senha incorretos.'), findsOneWidget);
      expect(loggedIn, isNull);
    });

    testWidgets('conta de demonstração entra (sem diferenciar maiúsculas)',
        (tester) async {
      await pumpLogin(tester);
      await tester.enterText(
          find.byKey(const ValueKey('login-username')), ' corujaazul42 ');
      await tester.enterText(find.byKey(const ValueKey('login-password')),
          AuthRepository.demoPassword);
      await _tap(tester, find.text('Acessar minhas trilhas'));
      await _server(tester);

      expect(loggedIn?.username, AuthRepository.demoUsername);
    });

    testWidgets('criar conta: gera nome, mostra o código e entra',
        (tester) async {
      await pumpLogin(tester);
      await _tap(tester, find.text('Criar conta'));
      await tester.pumpAndSettle();

      final nameFinder = find.byKey(const ValueKey('suggested-username'));
      final first = tester.widget<Text>(nameFinder).data;
      await _tap(tester, find.text('Gerar outro'));
      await tester.pump();
      final second = tester.widget<Text>(nameFinder).data;
      expect(second, isNot(first));

      await tester.enterText(
          find.byKey(const ValueKey('signup-password')), 'minhasenha1');
      await tester.enterText(
          find.byKey(const ValueKey('signup-confirm')), 'minhasenha1');
      await _tap(tester, find.text('Criar minha conta'));
      await _server(tester);

      expect(find.text('CÓDIGO DE RECUPERAÇÃO'), findsOneWidget);
      expect(find.text(second!), findsOneWidget);

      // Só continua depois de confirmar que guardou o código.
      await _tap(tester, find.text('Continuar'));
      await tester.pump();
      expect(loggedIn, isNull);

      await _tap(tester, find.byKey(const ValueKey('saved-code')));
      await tester.pump();
      await _tap(tester, find.text('Continuar'));
      await tester.pump();
      expect(loggedIn?.username, second);
    });

    testWidgets('recuperar senha com o código da conta', (tester) async {
      await pumpLogin(tester);
      await _tap(tester, find.text('Esqueci minha senha'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const ValueKey('recover-username')),
          AuthRepository.demoUsername);
      await tester.enterText(
          find.byKey(const ValueKey('recover-code')), 'k7m2 qx9p');
      await tester.enterText(
          find.byKey(const ValueKey('recover-password')), 'novasenha2');
      await tester.enterText(
          find.byKey(const ValueKey('recover-confirm')), 'novasenha2');
      await _tap(tester, find.text('Redefinir senha'));
      await _server(tester);

      expect(find.text('Senha redefinida!'), findsOneWidget);

      // A senha nova já funciona.
      final result = auth.login(AuthRepository.demoUsername, 'novasenha2');
      await tester.pump(AuthRepository.latency);
      expect(await result, isA<LoginOk>());
    });

    testWidgets('código errado não redefine a senha', (tester) async {
      await pumpLogin(tester);
      await _tap(tester, find.text('Esqueci minha senha'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const ValueKey('recover-username')),
          AuthRepository.demoUsername);
      await tester.enterText(
          find.byKey(const ValueKey('recover-code')), 'AAAA-BBBB');
      await tester.enterText(
          find.byKey(const ValueKey('recover-password')), 'novasenha2');
      await tester.enterText(
          find.byKey(const ValueKey('recover-confirm')), 'novasenha2');
      await _tap(tester, find.text('Redefinir senha'));
      await _server(tester);

      expect(find.text('Nome de usuário ou código incorretos.'), findsOneWidget);
    });
  });
}
