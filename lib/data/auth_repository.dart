import 'dart:math';

import 'username_generator.dart';

/// Usuário autenticado.
///
/// LGPD: o app não guarda nome real, CPF nem e-mail. O aluno é identificado
/// só pelo nome de usuário aleatório (ex.: "CorujaAzul42").
class AppUser {
  const AppUser({required this.username});

  final String username;

  /// Nome mostrado na saudação ("Bom estudo, CorujaAzul42").
  String get displayName => username;
}

/// Resultado do login.
sealed class LoginResult {
  const LoginResult();
}

class LoginOk extends LoginResult {
  const LoginOk(this.user);
  final AppUser user;
}

class LoginInvalid extends LoginResult {
  const LoginInvalid();
}

/// Conta recém-criada (ou senha redefinida) com o código de recuperação
/// que o aluno precisa guardar. O código só aparece nesse momento.
class AccountWithCode {
  const AccountWithCode(this.user, this.recoveryCode);
  final AppUser user;
  final String recoveryCode;
}

/// Muitas tentativas erradas de código de recuperação: conta bloqueada por
/// alguns minutos.
class AuthBlockedException implements Exception {
  const AuthBlockedException();
}

/// Contas: login, criar conta, recuperar senha e sair.
///
/// Duas implementações: [MockAuthRepository] (em memória, para testes e para
/// rodar sem internet) e `SupabaseAuthRepository` (banco de verdade).
abstract class AuthRepository {
  /// Repositório em memória, com a conta de demonstração.
  factory AuthRepository.demo({Random? random}) = MockAuthRepository;

  /// Instância usada pelo app. O `main.dart` troca pelo Supabase; os testes
  /// passam a própria.
  static AuthRepository shared = MockAuthRepository();

  /// Conta pronta para testar o app (listada no README).
  static const demoUsername = 'CorujaAzul42';
  static const demoPassword = 'trilha2026';
  static const demoRecoveryCode = 'K7M2-QX9P';

  /// Tempo simulado de ida ao servidor (só no mock).
  static const latency = Duration(milliseconds: 600);

  /// Aluno com sessão salva (para pular o login), ou `null`.
  AppUser? get currentUser;

  /// Sugere um nome de usuário aleatório.
  String suggestUsername();

  /// Entrar com nome de usuário + senha.
  Future<LoginResult> login(String username, String password);

  /// Cria a conta com o nome sugerido e devolve o código de recuperação.
  /// Devolve `null` se o nome já estiver em uso.
  Future<AccountWithCode?> signUp(String username, String password);

  /// Redefine a senha com o código de recuperação; o código antigo deixa de
  /// valer e um novo é gerado. Devolve `null` se o nome ou o código não
  /// conferem. Lança [AuthBlockedException] depois de muitas tentativas.
  Future<AccountWithCode?> resetPassword({
    required String username,
    required String recoveryCode,
    required String newPassword,
  });

  /// Sair da conta.
  Future<void> logout();

  /// Regras da senha. Devolve a mensagem de erro, ou `null` se estiver ok.
  static String? validatePassword(String value) {
    if (value.length < 8) return 'Use pelo menos 8 caracteres';
    if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
        !RegExp(r'\d').hasMatch(value)) {
      return 'Use letras e números';
    }
    return null;
  }
}

/// Autenticação em memória (sem back-end): usada nos testes e quando o app
/// roda com `--dart-define=USE_MOCK=true`.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({Random? random})
      : _random = random ?? Random.secure(),
        _accounts = {
          _key(AuthRepository.demoUsername): _Account(
            const AppUser(username: AuthRepository.demoUsername),
            password: AuthRepository.demoPassword,
            recoveryCode: AuthRepository.demoRecoveryCode,
          ),
        };

  final Random _random;
  final Map<String, _Account> _accounts;

  static String _key(String username) => username.trim().toLowerCase();

  @override
  AppUser? get currentUser => null;

  @override
  String suggestUsername() {
    final generator = UsernameGenerator(_random);
    while (true) {
      final name = generator.next();
      if (!_accounts.containsKey(_key(name))) return name;
    }
  }

  @override
  Future<LoginResult> login(String username, String password) async {
    await Future<void>.delayed(AuthRepository.latency);
    final account = _accounts[_key(username)];
    if (account == null || account.password != password) {
      return const LoginInvalid();
    }
    return LoginOk(account.user);
  }

  @override
  Future<AccountWithCode?> signUp(String username, String password) async {
    await Future<void>.delayed(AuthRepository.latency);
    final key = _key(username);
    if (_accounts.containsKey(key)) return null;
    final user = AppUser(username: username.trim());
    final code = generateRecoveryCode(_random);
    _accounts[key] = _Account(user, password: password, recoveryCode: code);
    return AccountWithCode(user, code);
  }

  @override
  Future<AccountWithCode?> resetPassword({
    required String username,
    required String recoveryCode,
    required String newPassword,
  }) async {
    await Future<void>.delayed(AuthRepository.latency);
    final account = _accounts[_key(username)];
    if (account == null ||
        account.recoveryCode != normalizeRecoveryCode(recoveryCode)) {
      return null;
    }
    final code = generateRecoveryCode(_random);
    account
      ..password = newPassword
      ..recoveryCode = code;
    return AccountWithCode(account.user, code);
  }

  @override
  Future<void> logout() async {}
}

class _Account {
  _Account(this.user, {required this.password, required this.recoveryCode});

  final AppUser user;
  String password;
  String recoveryCode;
}
