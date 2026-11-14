import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jornadatech/data/auth_repository.dart';
import 'package:jornadatech/data/cpf.dart';
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

void main() {
  group('CPF', () {
    test('aceita CPFs válidos, com ou sem máscara', () {
      expect(isValidCpf('529.982.247-25'), isTrue);
      expect(isValidCpf('11144477735'), isTrue);
    });

    test('recusa dígito verificador errado e números repetidos', () {
      expect(isValidCpf('529.982.247-26'), isFalse);
      expect(isValidCpf('111.111.111-11'), isFalse);
      expect(isValidCpf('1234'), isFalse);
    });
  });

  group('Nova senha', () {
    test('exige 8+ caracteres, letras e números e não aceita a padrão', () {
      expect(AuthRepository.validateNewPassword('abc12'), isNotNull);
      expect(AuthRepository.validateNewPassword('abcdefgh'), isNotNull);
      expect(AuthRepository.validateNewPassword(AuthRepository.defaultPassword),
          isNotNull);
      expect(AuthRepository.validateNewPassword('trilha2026'), isNull);
    });
  });

  group('Login', () {
    late AuthRepository auth;
    AppUser? loggedIn;

    Future<void> pumpLogin(WidgetTester tester) async {
      _phone(tester);
      auth = AuthRepository.demo();
      loggedIn = null;
      await tester.pumpWidget(MaterialApp(
        home: JornadaLoginScreen(
          auth: auth,
          onLoggedIn: (u) => loggedIn = u,
        ),
      ));
    }

    testWidgets('mostra os textos do Figma', (tester) async {
      await pumpLogin(tester);
      expect(find.text('CESUCA · METAMORFOSE'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('NOME COMPLETO'), findsOneWidget);
      expect(find.text('Acessar minhas trilhas'), findsOneWidget);
      expect(find.text('Primeiro acesso'), findsOneWidget);
    });

    testWidgets('senha errada mostra aviso e não entra', (tester) async {
      await pumpLogin(tester);
      await tester.enterText(
          find.byKey(const ValueKey('login-name')), 'Ana Beatriz Ribeiro da Silva');
      await tester.enterText(
          find.byKey(const ValueKey('login-password')), 'errada');
      await _tap(tester, find.text('Acessar minhas trilhas'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Nome completo ou senha incorretos.'), findsOneWidget);
      expect(loggedIn, isNull);
    });

    testWidgets('senha padrão leva à troca de senha e depois entra',
        (tester) async {
      await pumpLogin(tester);
      await tester.enterText(find.byKey(const ValueKey('login-name')),
          '  ana BEATRIZ ribeiro da silva ');
      await tester.enterText(find.byKey(const ValueKey('login-password')),
          AuthRepository.defaultPassword);
      await _tap(tester, find.text('Acessar minhas trilhas'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Defina sua nova senha'), findsOneWidget);

      await tester.enterText(
          find.byKey(const ValueKey('new-password')), 'trilha2026');
      await tester.enterText(
          find.byKey(const ValueKey('confirm-password')), 'trilha2026');
      await _tap(tester, find.text('Salvar e continuar'));
      await tester.pump(const Duration(seconds: 1));

      // O nome volta no formato do cadastro, não em minúsculas.
      expect(loggedIn?.fullName, 'Ana Beatriz Ribeiro da Silva');
      expect(loggedIn?.displayName, 'Ana Beatriz');

      // Com a senha nova, o próximo login já é direto.
      final result = auth.login('Ana Beatriz Ribeiro da Silva', 'trilha2026');
      await tester.pump(const Duration(seconds: 1));
      expect(await result, isA<LoginOk>());
    });

    testWidgets('CPF inválido não consulta o servidor', (tester) async {
      await pumpLogin(tester);
      await tester.enterText(
          find.byKey(const ValueKey('login-cpf')), '52998224726');
      await _tap(tester, find.text('Verificar'));
      await tester.pump();

      expect(find.text('CPF inválido'), findsOneWidget);
    });

    testWidgets('CPF válido de primeiro acesso abre a troca de senha',
        (tester) async {
      await pumpLogin(tester);
      await tester.enterText(
          find.byKey(const ValueKey('login-cpf')), '11144477735');
      expect(find.text('111.444.777-35'), findsOneWidget); // máscara
      await _tap(tester, find.text('Verificar'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Defina sua nova senha'), findsOneWidget);
      expect(find.textContaining('Carlos Eduardo'), findsOneWidget);
    });
  });
}
