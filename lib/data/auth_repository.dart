import 'cpf.dart';

/// Usuário autenticado.
class AppUser {
  const AppUser({required this.fullName, required this.cpf});

  final String fullName;
  final String cpf;

  /// Os dois primeiros nomes, para a saudação ("Ana Beatriz").
  String get displayName => fullName.split(RegExp(r'\s+')).take(2).join(' ');
}

/// Resultado do login.
sealed class LoginResult {
  const LoginResult();
}

class LoginOk extends LoginResult {
  const LoginOk(this.user);
  final AppUser user;
}

/// Senha certa, mas ainda é a padrão: precisa trocar antes de entrar (RF003).
class LoginNeedsNewPassword extends LoginResult {
  const LoginNeedsNewPassword(this.user);
  final AppUser user;
}

class LoginInvalid extends LoginResult {
  const LoginInvalid();
}

/// Autenticação de demonstração, em memória (sem back-end).
///
/// MOCK: os usuários, CPFs e a senha padrão abaixo existem só para o
/// protótipo. Num app real isso fica no servidor e nada disso vai no código.
class AuthRepository {
  AuthRepository.demo()
      : _users = {
          for (final u in _demoUsers) _key(u.fullName): _Account(u),
        };

  /// Instância usada pelo app (os testes criam a própria).
  static final shared = AuthRepository.demo();

  /// RF002: senha padrão do primeiro acesso.
  static const defaultPassword = 'Mudar@123';

  static const _demoUsers = [
    AppUser(fullName: 'Ana Beatriz Ribeiro da Silva', cpf: '52998224725'),
    AppUser(fullName: 'Carlos Eduardo Santos', cpf: '11144477735'),
  ];

  /// Simula a ida ao servidor.
  static const latency = Duration(milliseconds: 800);

  final Map<String, _Account> _users;

  static String _key(String name) =>
      name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// RF001: login com nome completo + senha.
  Future<LoginResult> login(String fullName, String password) async {
    await Future<void>.delayed(latency);
    final account = _users[_key(fullName)];
    if (account == null || account.password != password) {
      return const LoginInvalid();
    }
    return account.pendingFirstAccess
        ? LoginNeedsNewPassword(account.user)
        : LoginOk(account.user);
  }

  /// RF003: confirma a identidade pelo CPF. Devolve o usuário só se ele
  /// ainda não definiu a própria senha.
  Future<AppUser?> findFirstAccessByCpf(String cpf) async {
    await Future<void>.delayed(latency);
    final digits = cpfDigits(cpf);
    for (final account in _users.values) {
      if (account.user.cpf == digits && account.pendingFirstAccess) {
        return account.user;
      }
    }
    return null;
  }

  /// RF003: define a nova senha e libera o acesso.
  Future<void> setNewPassword(AppUser user, String newPassword) async {
    await Future<void>.delayed(latency);
    final account = _users[_key(user.fullName)]!;
    account
      ..password = newPassword
      ..pendingFirstAccess = false;
  }

  /// Regras da nova senha. Devolve a mensagem de erro, ou `null` se estiver ok.
  static String? validateNewPassword(String value) {
    if (value.length < 8) return 'Use pelo menos 8 caracteres';
    if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
        !RegExp(r'\d').hasMatch(value)) {
      return 'Use letras e números';
    }
    if (value == defaultPassword) return 'Escolha uma senha diferente da padrão';
    return null;
  }
}

class _Account {
  _Account(this.user);

  final AppUser user;
  String password = AuthRepository.defaultPassword;
  bool pendingFirstAccess = true;
}
