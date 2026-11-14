import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';
import 'username_generator.dart';

/// Contas no Supabase, sem dados pessoais (LGPD).
///
/// O Supabase Auth exige e-mail, então o app monta um e-mail interno que não
/// existe a partir do nome de usuário (`corujaazul42@alunos.jornadatech.dev.br`).
/// O aluno nunca vê isso; a confirmação de e-mail fica desligada no painel.
/// Veja `supabase/schema.sql` e `supabase/README.md`.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client, {Random? random})
      : _random = random ?? Random.secure();

  final SupabaseClient _client;
  final Random _random;

  static const _emailDomain = 'alunos.jornadatech.dev.br';

  static String _email(String username) =>
      '${username.trim().toLowerCase()}@$_emailDomain';

  /// O nome de usuário fica nos metadados da conta (gravados no signUp).
  static AppUser _toAppUser(User user) {
    final name = user.userMetadata?['nome_usuario'] as String?;
    return AppUser(username: name ?? user.email?.split('@').first ?? 'Aluno');
  }

  @override
  AppUser? get currentUser {
    final user = _client.auth.currentUser;
    return user == null ? null : _toAppUser(user);
  }

  @override
  String suggestUsername() => UsernameGenerator(_random).next();

  @override
  Future<LoginResult> login(String username, String password) async {
    try {
      final res = await _client.auth
          .signInWithPassword(email: _email(username), password: password);
      final user = res.user;
      return user == null ? const LoginInvalid() : LoginOk(_toAppUser(user));
    } on AuthRetryableFetchException {
      rethrow; // sem internet: a tela mostra outra mensagem
    } on AuthException {
      return const LoginInvalid();
    }
  }

  @override
  Future<AccountWithCode?> signUp(String username, String password) async {
    final name = username.trim();
    final free = await _client
        .rpc<bool>('nome_usuario_disponivel', params: {'nome': name});
    if (!free) return null;

    final AuthResponse res;
    try {
      res = await _client.auth.signUp(
        email: _email(name),
        password: password,
        data: {'nome_usuario': name},
      );
    } on AuthException {
      // Ex.: alguém criou o mesmo nome entre a checagem e o cadastro.
      return null;
    }
    if (res.user == null || res.session == null) {
      // Sem sessão = confirmação de e-mail ainda ligada no painel.
      throw StateError(
          'Desligue "Confirm email" em Authentication → Providers → Email.');
    }

    final code = generateRecoveryCode(_random);
    await _client
        .rpc<void>('definir_codigo_recuperacao', params: {'codigo': code});
    return AccountWithCode(_toAppUser(res.user!), code);
  }

  @override
  Future<AccountWithCode?> resetPassword({
    required String username,
    required String recoveryCode,
    required String newPassword,
  }) async {
    final newCode = generateRecoveryCode(_random);
    final result = await _client.rpc<String>(
      'redefinir_senha_com_codigo',
      params: {
        'nome': username.trim(),
        'codigo': normalizeRecoveryCode(recoveryCode),
        'nova_senha': newPassword,
        'novo_codigo': newCode,
      },
    );
    switch (result) {
      case 'ok':
        // Entra com a senha nova para abrir a sessão.
        final login = await this.login(username, newPassword);
        return switch (login) {
          LoginOk(:final user) => AccountWithCode(user, newCode),
          LoginInvalid() => null,
        };
      case 'bloqueado':
        throw const AuthBlockedException();
      default:
        return null;
    }
  }

  @override
  Future<void> logout() => _client.auth.signOut();
}
