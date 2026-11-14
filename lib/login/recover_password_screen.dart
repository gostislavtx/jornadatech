import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../ui/app_tokens.dart';
import '../ui/app_widgets.dart';
import 'auth_scaffold.dart';
import 'recovery_code_screen.dart';

/// "Esqueci minha senha": nome de usuário + código de recuperação.
class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key, required this.auth, this.onDone});

  final AuthRepository auth;
  final ValueChanged<AppUser>? onDone;

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final AccountWithCode? account;
    try {
      account = await widget.auth.resetPassword(
        username: _userCtrl.text,
        recoveryCode: _codeCtrl.text,
        newPassword: _passCtrl.text,
      );
    } on AuthBlockedException {
      if (!mounted) return;
      setState(() => _loading = false);
      showAppSnack(context,
          'Muitas tentativas erradas. Tente de novo em 15 minutos.');
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      showAppSnack(context, 'Sem conexão com o servidor. Tente de novo.');
      return;
    }
    if (!mounted) return;
    setState(() => _loading = false);

    if (account == null) {
      showAppSnack(context, 'Nome de usuário ou código incorretos.');
      return;
    }
    // O código antigo deixa de valer: mostra o novo.
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => RecoveryCodeScreen(
        account: account,
        title: 'Senha redefinida!',
        onContinue: (user) => widget.onDone?.call(user),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Recuperar senha',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Esqueceu a senha?', style: AppText.sora(18, height: 28)),
            const SizedBox(height: 4),
            Text(
              'Use o código de recuperação que apareceu quando você criou a '
              'conta.',
              style: AppText.manrope(14, height: 20),
            ),
            const SizedBox(height: 24),
            Text('NOME DE USUÁRIO', style: AppText.label()),
            const SizedBox(height: 8),
            TextFormField(
              key: const ValueKey('recover-username'),
              controller: _userCtrl,
              enabled: !_loading,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              style: AppText.manrope(14, color: AppColors.text, height: 20),
              decoration: appFieldDecoration(
                hintText: 'Ex.: CorujaAzul42',
                icon: Icons.person_outline_rounded,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Informe seu nome de usuário'
                  : null,
            ),
            const SizedBox(height: 16),
            Text('CÓDIGO DE RECUPERAÇÃO', style: AppText.label()),
            const SizedBox(height: 8),
            TextFormField(
              key: const ValueKey('recover-code'),
              controller: _codeCtrl,
              enabled: !_loading,
              autocorrect: false,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              style: AppText.manrope(14, color: AppColors.text, height: 20),
              decoration: appFieldDecoration(
                hintText: 'XXXX-XXXX',
                icon: Icons.key_outlined,
              ),
              validator: (v) => (v ?? '')
                          .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
                          .length !=
                      8
                  ? 'O código tem 8 letras e números'
                  : null,
            ),
            const SizedBox(height: 16),
            PasswordField(
              label: 'Nova senha',
              fieldKey: const ValueKey('recover-password'),
              controller: _passCtrl,
              enabled: !_loading,
              validator: (v) => AuthRepository.validatePassword(v ?? ''),
            ),
            const SizedBox(height: 16),
            PasswordField(
              label: 'Confirme a nova senha',
              fieldKey: const ValueKey('recover-confirm'),
              controller: _confirmCtrl,
              enabled: !_loading,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (v) =>
                  v != _passCtrl.text ? 'As senhas não coincidem' : null,
            ),
            const SizedBox(height: 24),
            PrimaryButton('Redefinir senha',
                loading: _loading, onPressed: _submit),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.mutedBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.support_outlined,
                      size: 18, color: AppColors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Perdeu também o código? Fale com o professor ou o '
                      'monitor da sua turma do Metamorfose: ele pode '
                      'redefinir sua senha.',
                      style: AppText.manrope(12, height: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
