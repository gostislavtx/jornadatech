import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/auth_repository.dart';
import '../ui/app_tokens.dart';
import '../ui/app_widgets.dart';
import 'auth_scaffold.dart';

/// Mostra o nome de usuário e o código de recuperação logo depois de criar a
/// conta (ou de redefinir a senha). É a única vez que o código aparece.
class RecoveryCodeScreen extends StatefulWidget {
  const RecoveryCodeScreen({
    super.key,
    required this.account,
    required this.onContinue,
    this.title = 'Conta criada!',
  });

  final AccountWithCode account;
  final ValueChanged<AppUser> onContinue;
  final String title;

  @override
  State<RecoveryCodeScreen> createState() => _RecoveryCodeScreenState();
}

class _RecoveryCodeScreenState extends State<RecoveryCodeScreen> {
  bool _saved = false;

  Future<void> _copy() async {
    final a = widget.account;
    await Clipboard.setData(ClipboardData(
      text: 'JornadaTech\n'
          'Nome de usuário: ${a.user.username}\n'
          'Código de recuperação: ${a.recoveryCode}',
    ));
    if (!mounted) return;
    showAppSnack(context, 'Copiado! Guarde num lugar seguro.');
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.account;
    return PopScope(
      // Sem voltar: o aluno precisa confirmar que guardou o código.
      canPop: false,
      child: AuthScaffold(
        title: widget.title,
        showBack: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Guarde estes dados', style: AppText.sora(18, height: 28)),
            const SizedBox(height: 4),
            Text(
              'Você vai precisar do nome de usuário para entrar e do código '
              'se esquecer a senha. Anote num papel ou tire um print.',
              style: AppText.manrope(14, height: 20),
            ),
            const SizedBox(height: 24),
            _box('NOME DE USUÁRIO', a.user.username, AppColors.blue,
                AppColors.blueSoft),
            const SizedBox(height: 12),
            _box('CÓDIGO DE RECUPERAÇÃO', a.recoveryCode,
                AppColors.accentInk, AppColors.orangeSoft),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _copy,
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copiar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.blue,
                side: const BorderSide(color: AppColors.border),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              key: const ValueKey('saved-code'),
              value: _saved,
              onChanged: (v) => setState(() => _saved = v ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.orange,
              title: Text('Guardei meu nome de usuário e o código',
                  style:
                      AppText.manrope(14, color: AppColors.text, height: 20)),
            ),
            const SizedBox(height: 8),
            Opacity(
              opacity: _saved ? 1 : 0.5,
              child: PrimaryButton(
                'Continuar',
                onPressed: () {
                  if (_saved) {
                    widget.onContinue(a.user);
                  } else {
                    showAppSnack(context, 'Confirme que guardou o código.');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(String label, String value, Color color, Color background) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.label(color: color)),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: AppText.sora(22, color: color, height: 30,
                letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}
