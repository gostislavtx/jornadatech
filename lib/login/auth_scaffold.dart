import 'package:flutter/material.dart';

import '../ui/app_tokens.dart';
import '../ui/app_widgets.dart';

/// Moldura das telas secundárias do login (criar conta, recuperar senha,
/// código de recuperação): barra em degradê e conteúdo centralizado.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.child,
    this.showBack = true,
  });

  final String title;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        title: Text(title,
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
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Campo de senha com rótulo em maiúsculas e botão de mostrar/esconder.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.onSubmitted,
    this.textInputAction = TextInputAction.next,
    this.fieldKey,
  });

  /// Chave do campo (usada nos testes).
  final Key? fieldKey;

  final String label;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label.toUpperCase(), style: AppText.label()),
        const SizedBox(height: 8),
        TextFormField(
          key: widget.fieldKey,
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: _obscure,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          style: AppText.manrope(14, color: AppColors.text, height: 20),
          decoration: appFieldDecoration(
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
          validator: widget.validator,
        ),
      ],
    );
  }
}
