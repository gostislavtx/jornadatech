import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/auth_repository.dart';
import '../data/cpf.dart';
import '../splash/widgets/jornada_logo.dart';
import '../ui/app_tokens.dart';
import '../ui/app_widgets.dart';

/// Tela 01 do Figma — Login / primeiro acesso.
///
/// RF001: entrar com nome completo + senha.
/// RF003: primeiro acesso confirmado pelo CPF, com troca de senha obrigatória.
class JornadaLoginScreen extends StatefulWidget {
  const JornadaLoginScreen({super.key, this.onLoggedIn, this.auth});

  /// Chamado quando o login (ou a troca de senha do primeiro acesso) termina.
  final ValueChanged<AppUser>? onLoggedIn;

  /// Padrão: [AuthRepository.shared]. Os testes passam uma instância nova.
  final AuthRepository? auth;

  @override
  State<JornadaLoginScreen> createState() => _JornadaLoginScreenState();
}

class _JornadaLoginScreenState extends State<JornadaLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cpfFormKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  bool _loading = false, _obscure = true, _verifyingCpf = false;

  AuthRepository get _auth => widget.auth ?? AuthRepository.shared;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passCtrl.dispose();
    _cpfCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final result = await _auth.login(_nameCtrl.text, _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case LoginInvalid():
        showAppSnack(context, 'Nome completo ou senha incorretos.');
      case LoginNeedsNewPassword(:final user):
        _openChangePassword(user);
      case LoginOk(:final user):
        widget.onLoggedIn?.call(user);
    }
  }

  Future<void> _verifyCpf() async {
    FocusScope.of(context).unfocus();
    if (!_cpfFormKey.currentState!.validate()) return;
    setState(() => _verifyingCpf = true);
    final user = await _auth.findFirstAccessByCpf(_cpfCtrl.text);
    if (!mounted) return;
    setState(() => _verifyingCpf = false);

    if (user == null) {
      showAppSnack(context, 'CPF não encontrado ou já tem senha definida.');
    } else {
      _openChangePassword(user);
    }
  }

  void _openChangePassword(AppUser user) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ChangePasswordScreen(
        user: user,
        auth: _auth,
        onDone: widget.onLoggedIn,
      ),
    ));
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Entrar', style: AppText.sora(18, height: 28)),
              const SizedBox(height: 4),
              Text('Use o mesmo nome completo do cadastro no projeto.',
                  style: AppText.manrope(14, height: 20)),
              const SizedBox(height: 24),
              Text('NOME COMPLETO', style: AppText.label()),
              const SizedBox(height: 8),
              TextFormField(
                key: const ValueKey('login-name'),
                controller: _nameCtrl,
                enabled: !_loading,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                style: AppText.manrope(14, color: AppColors.text, height: 20),
                decoration: appFieldDecoration(
                  hintText: 'Seu nome completo',
                  icon: Icons.person_outline_rounded,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null,
              ),
              const SizedBox(height: 16),
              Text('SENHA', style: AppText.label()),
              const SizedBox(height: 8),
              TextFormField(
                key: const ValueKey('login-password'),
                controller: _passCtrl,
                enabled: !_loading,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                autofillHints: const [AutofillHints.password],
                style: AppText.manrope(14, color: AppColors.text, height: 20),
                decoration: appFieldDecoration(
                  hintText: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  suffix: IconButton(
                    tooltip: _obscure ? 'Mostrar senha' : 'Esconder senha',
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: AppColors.muted,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe sua senha' : null,
              ),
              const SizedBox(height: 24),
              PrimaryButton('Acessar minhas trilhas',
                  loading: _loading, onPressed: _submit),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _firstAccessCard(),
        const SizedBox(height: 20),
        _odsNote(),
      ],
    );
  }

  /// RF003: card "Primeiro acesso" (borda tracejada laranja).
  Widget _firstAccessCard() {
    return DashedBorderBox(
      color: const Color(0x80EA4A00),
      background: AppColors.orangeSoft,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _cpfFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fingerprint_rounded,
                    size: 16, color: AppColors.accentInk),
                const SizedBox(width: 8),
                Text('Primeiro acesso',
                    style: AppText.sora(14,
                        color: AppColors.accentInk, height: 20)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Confirmamos sua identidade pelo CPF e você define uma nova senha.',
              style: AppText.manrope(12,
                  color: const Color(0xCC921300), height: 16),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const ValueKey('login-cpf'),
              controller: _cpfCtrl,
              enabled: !_verifyingCpf,
              keyboardType: TextInputType.number,
              inputFormatters: [CpfInputFormatter()],
              onFieldSubmitted: (_) => _verifyCpf(),
              style: AppText.manrope(14, color: AppColors.text, height: 20),
              decoration: InputDecoration(
                hintText: 'CPF 000.000.000-00',
                hintStyle:
                    AppText.manrope(14, color: AppColors.text, height: 20),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                errorStyle:
                    AppText.manrope(12, color: AppColors.accentInk),
                suffixIcon: _verifyingCpf
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.orange),
                        ),
                      )
                    : TextButton(
                        onPressed: _verifyCpf,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.orange,
                          textStyle: AppText.sora(12, height: 16),
                        ),
                        child: const Text('Verificar'),
                      ),
              ),
              validator: (v) => isValidCpf(v ?? '') ? null : 'CPF inválido',
            ),
          ],
        ),
      ),
    );
  }

  Widget _odsNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.eco_outlined, size: 14, color: AppColors.muted),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'Educação de qualidade (ODS 4) e redução de desigualdades (ODS 10)',
            textAlign: TextAlign.center,
            style: AppText.manrope(11, height: 16.5),
          ),
        ),
      ],
    );
  }
}

/// RF003: troca de senha obrigatória no primeiro acesso.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
    required this.user,
    required this.auth,
    this.onDone,
  });

  final AppUser user;
  final AuthRepository auth;
  final ValueChanged<AppUser>? onDone;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await widget.auth.setNewPassword(widget.user, _newPassCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    widget.onDone?.call(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Nova senha',
            style: AppText.sora(18, color: AppColors.onPrimary)),
        foregroundColor: AppColors.onPrimary,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.headerGradient),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Defina sua nova senha',
                      style: AppText.sora(18, height: 28)),
                  const SizedBox(height: 4),
                  Text(
                    'Olá, ${widget.user.displayName}! Mínimo de 8 caracteres, '
                    'com letras e números.',
                    style: AppText.manrope(14, height: 20),
                  ),
                  const SizedBox(height: 24),
                  Text('NOVA SENHA', style: AppText.label()),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const ValueKey('new-password'),
                    controller: _newPassCtrl,
                    enabled: !_loading,
                    obscureText: true,
                    style:
                        AppText.manrope(14, color: AppColors.text, height: 20),
                    decoration:
                        appFieldDecoration(icon: Icons.lock_outline_rounded),
                    validator: (v) =>
                        AuthRepository.validateNewPassword(v ?? ''),
                  ),
                  const SizedBox(height: 16),
                  Text('CONFIRMAR SENHA', style: AppText.label()),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const ValueKey('confirm-password'),
                    controller: _confirmCtrl,
                    enabled: !_loading,
                    obscureText: true,
                    onFieldSubmitted: (_) => _submit(),
                    style:
                        AppText.manrope(14, color: AppColors.text, height: 20),
                    decoration:
                        appFieldDecoration(icon: Icons.lock_outline_rounded),
                    validator: (v) => v != _newPassCtrl.text
                        ? 'As senhas não coincidem'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton('Salvar e continuar',
                      loading: _loading, onPressed: _submit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
