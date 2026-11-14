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

/// Autenticação de demonstração, em memória (sem back-end).
///
/// MOCK: será trocado pelo Supabase mantendo os mesmos métodos. Lá a senha e
/// o código de recuperação ficam só como hash, nunca em texto puro.
class AuthRepository {
  AuthRepository.demo({Random? random})
      : _random = random ?? Random.secure(),
        _accounts = {
          _key(demoUsername): _Account(
            const AppUser(username: demoUsername),
            password: demoPassword,
            recoveryCode: demoRecoveryCode,
          ),
        };

  /// Instância usada pelo app (os testes criam a própria).
  static final shared = AuthRepository.demo();

  /// Conta pronta para testar o app (listada no README).
  static const demoUsername = 'CorujaAzul42';
  static const demoPassword = 'trilha2026';
  static const demoRecoveryCode = 'K7M2-QX9P';

  /// Simula a ida ao servidor.
  static const latency = Duration(milliseconds: 600);

  final Random _random;
  final Map<String, _Account> _accounts;

  static String _key(String username) => username.trim().toLowerCase();

  /// Sugere um nome de usuário que ainda não existe.
  String suggestUsername() {
    final generator = UsernameGenerator(_random);
    while (true) {
      final name = generator.next();
      if (!_accounts.containsKey(_key(name))) return name;
    }
  }

  /// Entrar com nome de usuário + senha.
  Future<LoginResult> login(String username, String password) async {
    await Future<void>.delayed(latency);
    final account = _accounts[_key(username)];
    if (account == null || account.password != password) {
      return const LoginInvalid();
    }
    return LoginOk(account.user);
  }

  /// Cria a conta com o nome sugerido e devolve o código de recuperação.
  /// Devolve `null` se alguém pegou esse nome nesse meio-tempo.
  Future<AccountWithCode?> signUp(String username, String password) async {
    await Future<void>.delayed(latency);
    final key = _key(username);
    if (_accounts.containsKey(key)) return null;
    final user = AppUser(username: username.trim());
    final code = generateRecoveryCode(_random);
    _accounts[key] =
        _Account(user, password: password, recoveryCode: code);
    return AccountWithCode(user, code);
  }

  /// Redefine a senha com o código de recuperação. O código antigo deixa de
  /// valer e um novo é gerado. Devolve `null` se o nome ou o código não
  /// conferem.
  Future<AccountWithCode?> resetPassword({
    required String username,
    required String recoveryCode,
    required String newPassword,
  }) async {
    await Future<void>.delayed(latency);
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

class _Account {
  _Account(this.user, {required this.password, required this.recoveryCode});

  final AppUser user;
  String password;
  String recoveryCode;
}
