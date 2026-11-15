import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../ui/app_tokens.dart';
import '../ui/app_widgets.dart';
import 'auth_scaffold.dart';
import 'recovery_code_screen.dart';

/// Criar conta sem dados pessoais (LGPD): o app sugere um nome de usuário
/// aleatório e o aluno só escolhe a senha.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key, required this.auth, this.onDone});

  final AuthRepository auth;
  final ValueChanged<AppUser>? onDone;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  late String _username = widget.auth.suggestUsername();
  bool _loading = false;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _anotherName() =>
      setState(() => _username = widget.auth.suggestUsername());

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final AccountWithCode? account;
    try {
      account = await widget.auth.signUp(_username, _passCtrl.text);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      showAppSnack(context, 'Não foi possível criar a conta. Tente de novo.');
      return;
    }
    if (!mounted) return;
    setState(() => _loading = false);

    if (account == null) {
      // Raro: outra pessoa criou o mesmo nome agora há pouco.
      _anotherName();
      showAppSnack(context, 'Esse nome acabou de ser usado. Geramos outro.');
      return;
    }
    // Variável não-nula para usar dentro do builder (closure).
    final created = account;
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => RecoveryCodeScreen(
        account: created,
        onContinue: (user) => widget.onDone?.call(user),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Criar conta',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Seu nome no JornadaTech',
                style: AppText.sora(18, height: 28)),
            const SizedBox(height: 4),
            Text(
              'Para proteger seus dados, não pedimos nome, CPF nem e-mail. '
              'Você entra com um nome de usuário criado pelo app.',
              style: AppText.manrope(14, height: 20),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              decoration: BoxDecoration(
                color: AppColors.blueSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.badge_outlined,
                      size: 20, color: AppColors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _username,
                      key: const ValueKey('suggested-username'),
                      style: AppText.sora(20, color: AppColors.blue,
                          height: 28),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _loading ? null : _anotherName,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Gerar outro'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.orange,
                      textStyle: AppText.sora(12, height: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PasswordField(
              label: 'Crie uma senha',
              fieldKey: const ValueKey('signup-password'),
              controller: _passCtrl,
              enabled: !_loading,
              validator: (v) => AuthRepository.validatePassword(v ?? ''),
            ),
            const SizedBox(height: 4),
            Text('Mínimo de 8 caracteres, com letras e números.',
                style: AppText.manrope(12, height: 16)),
            const SizedBox(height: 16),
            PasswordField(
              label: 'Confirme a senha',
              fieldKey: const ValueKey('signup-confirm'),
              controller: _confirmCtrl,
              enabled: !_loading,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (v) =>
                  v != _passCtrl.text ? 'As senhas não coincidem' : null,
            ),
            const SizedBox(height: 24),
            PrimaryButton('Criar minha conta',
                loading: _loading, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
