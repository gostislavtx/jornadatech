import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/auth_repository.dart';
import '../splash/widgets/jornada_logo.dart';
import '../ui/app_tokens.dart';
import '../ui/app_widgets.dart';
import 'auth_scaffold.dart';
import 'create_account_screen.dart';
import 'recover_password_screen.dart';

/// Tela 01 — Login.
///
/// LGPD: o aluno entra com um nome de usuário aleatório + senha. O app não
/// pede nome real, CPF nem e-mail (o Metamorfose atende crianças e
/// adolescentes, então coletamos o mínimo possível).
class JornadaLoginScreen extends StatefulWidget {
  const JornadaLoginScreen({super.key, this.onLoggedIn, this.auth});

  /// Chamado quando o aluno entra (login, conta nova ou senha redefinida).
  final ValueChanged<AppUser>? onLoggedIn;

  /// Padrão: [AuthRepository.shared]. Os testes passam uma instância nova.
  final AuthRepository? auth;

  @override
  State<JornadaLoginScreen> createState() => _JornadaLoginScreenState();
}

class _JornadaLoginScreenState extends State<JornadaLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  AuthRepository get _auth => widget.auth ?? AuthRepository.shared;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final LoginResult result;
    try {
      result = await _auth.login(_userCtrl.text, _passCtrl.text);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      showAppSnack(context, 'Sem conexão com o servidor. Tente de novo.');
      return;
    }
    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case LoginInvalid():
        showAppSnack(context, 'Nome de usuário ou senha incorretos.');
      case LoginOk(:final user):
        widget.onLoggedIn?.call(user);
    }
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(top),
              // A folha branca sobe 24 px por cima do degradê.
              Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: _form(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(double top) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      padding: EdgeInsets.fromLTRB(24, top + 48, 24, 40 + 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const JornadaLogo(size: 56, animate: false),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CESUCA · METAMORFOSE',
                      style: AppText.sora(11,
                          weight: FontWeight.w600,
                          color: const Color(0xCCFFFAF5),
                          height: 16.5,
                          letterSpacing: 2.2),
                    ),
                    Text('JornadaTech',
                        style: AppText.sora(20,
                            color: AppColors.onPrimary, height: 28)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Do aprendizado das aulas ao conteúdo aberto gratuito.',
            style: AppText.sora(24,
                weight: FontWeight.w800,
                color: AppColors.onPrimary,
                height: 30),
          ),
        ],
      ),
    );
  }

  Widget _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Entrar', style: AppText.sora(18, height: 28)),
              const SizedBox(height: 4),
              Text('Use o nome de usuário que o app criou para você.',
                  style: AppText.manrope(14, height: 20)),
              const SizedBox(height: 24),
              Text('NOME DE USUÁRIO', style: AppText.label()),
              const SizedBox(height: 8),
              TextFormField(
                key: const ValueKey('login-username'),
                controller: _userCtrl,
                enabled: !_loading,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
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
              PasswordField(
                label: 'Senha',
                fieldKey: const ValueKey('login-password'),
                controller: _passCtrl,
                enabled: !_loading,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe sua senha' : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () => _open(RecoverPasswordScreen(
                            auth: _auth,
                            onDone: widget.onLoggedIn,
                          )),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.blue,
                    textStyle: AppText.manrope(12,
                        weight: FontWeight.w700, height: 16),
                  ),
                  child: const Text('Esqueci minha senha'),
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton('Acessar minhas trilhas',
                  loading: _loading, onPressed: _submit),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _signUpCard(),
        const SizedBox(height: 20),
        _footnote(),
      ],
    );
  }

  /// Card "Primeira vez aqui?" (borda tracejada laranja, como no Figma).
  Widget _signUpCard() {
    return DashedBorderBox(
      color: const Color(0x80EA4A00),
      background: AppColors.orangeSoft,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_add_alt_rounded,
                  size: 16, color: AppColors.accentInk),
              const SizedBox(width: 8),
              Text('Primeira vez aqui?',
                  style: AppText.sora(14,
                      color: AppColors.accentInk, height: 20)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Crie sua conta em poucos segundos, sem informar nome, CPF ou '
            'e-mail.',
            style: AppText.manrope(12,
                color: const Color(0xCC921300), height: 16),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: FilledButton(
              onPressed: _loading
                  ? null
                  : () => _open(CreateAccountScreen(
                        auth: _auth,
                        onDone: widget.onLoggedIn,
                      )),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.orange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle: AppText.sora(13, height: 16),
              ),
              child: const Text('Criar conta'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footnote() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user_outlined,
                size: 14, color: AppColors.muted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Não coletamos dados pessoais (LGPD)',
                textAlign: TextAlign.center,
                style: AppText.manrope(11, height: 16.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.eco_outlined, size: 14, color: AppColors.muted),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Educação de qualidade (ODS 4) e redução de desigualdades '
                '(ODS 10)',
                textAlign: TextAlign.center,
                style: AppText.manrope(11, height: 16.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
