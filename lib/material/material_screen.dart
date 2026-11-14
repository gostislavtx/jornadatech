import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/catalog.dart';
import '../ui/app_tokens.dart';
import '../ui/app_widgets.dart';

/// Tela 03 do Figma — Material da trilha (aula atual).
class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key, required this.trilha});

  final Trilha trilha;

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  LessonStatus _status = LessonStatus.naoVisto;
  bool _savedOffline = false;

  Lesson get _lesson => widget.trilha.currentLesson;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _player(context),
              // O card branco sobe 20 px sobre o player.
              Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 19, 20, 12),
                  child: _content(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _player(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      height: 176 + top,
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      padding: EdgeInsets.fromLTRB(16, top + 16, 16, 0),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Semantics(
              button: true,
              label: 'Voltar',
              child: InkResponse(
                onTap: () => Navigator.of(context).maybePop(),
                radius: 22,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0x40FFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: StadiumBorder(),
              ),
              child: Text(
                'Aula ${_lesson.number} de ${widget.trilha.total}',
                style: AppText.manrope(11,
                    weight: FontWeight.w700,
                    color: AppColors.blue,
                    height: 16.5),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.1),
            child: Semantics(
              button: true,
              label: 'Abrir material',
              child: GestureDetector(
                onTap: () => showAppSnack(
                    context, 'Abrindo "${_lesson.title}" no ${_lesson.source}…'),
                child: const PlayBadge(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    final l = _lesson;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('${widget.trilha.title} · ${widget.trilha.origin.split(' · ').first}'
            .toUpperCase(),
            style: AppText.eyebrow()),
        const SizedBox(height: 3),
        Text(l.title, style: AppText.sora(18, height: 24.75)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _tag(
              icon: l.isVideo
                  ? Icons.smart_display_outlined
                  : Icons.language_rounded,
              label: '${l.source} · ${l.isFree ? 'gratuito' : 'pago'}',
              background: AppColors.orangeSoft,
              color: AppColors.accentInk,
            ),
            _tag(
              icon: Icons.workspace_premium_outlined,
              label: l.hasCertificate ? 'com certificado' : 'sem certificado',
              background: AppColors.blueSoft,
              color: AppColors.blue,
            ),
            _tag(label: '${l.minutes} min', outlined: true),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.mutedBg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cobre da ementa', style: AppText.sora(12, height: 16)),
              const SizedBox(height: 4),
              Text(l.syllabus, style: AppText.manrope(12, height: 19.5)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('MEU PROGRESSO', style: AppText.label()),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final s in LessonStatus.values) ...[
              if (s != LessonStatus.values.first) const SizedBox(width: 8),
              Expanded(child: _statusButton(s)),
            ],
          ],
        ),
        const SizedBox(height: 12),
        _offlineButton(),
        const SizedBox(height: 24),
        Text('Continue nesta trilha', style: AppText.sora(14, height: 20)),
        const SizedBox(height: 12),
        for (final item in l.related) ...[
          _relatedTile(item),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 12),
        _feedback(),
      ],
    );
  }

  Widget _tag({
    IconData? icon,
    required String label,
    Color background = Colors.transparent,
    Color color = AppColors.muted,
    bool outlined = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: background,
        shape: StadiumBorder(
          side: outlined
              ? const BorderSide(color: AppColors.border)
              : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: AppText.manrope(11,
                  weight: FontWeight.w600, color: color, height: 16.5)),
        ],
      ),
    );
  }

  Widget _statusButton(LessonStatus s) {
    final selected = s == _status;
    final (Color bg, Color border, Color fg) = switch ((s, selected)) {
      (_, false) => (Colors.white, AppColors.border, AppColors.muted),
      (LessonStatus.naoVisto, true) =>
        (AppColors.mutedBg, AppColors.muted, AppColors.ink),
      (LessonStatus.visto, true) =>
        (AppColors.orangeSoft, AppColors.orange, AppColors.accentInk),
      (LessonStatus.concluido, true) =>
        (AppColors.orange, AppColors.orange, AppColors.onPrimary),
    };
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border),
        ),
        child: InkWell(
          key: ValueKey('status-${s.name}'),
          customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          onTap: () => setState(() => _status = s),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(s.icon, size: 16, color: fg),
                const SizedBox(height: 3),
                Text(s.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.manrope(11,
                        weight: selected ? FontWeight.w700 : FontWeight.w600,
                        color: fg,
                        height: 16.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _offlineButton() {
    return SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() => _savedOffline = !_savedOffline);
          showAppSnack(
            context,
            _savedOffline
                ? 'Material salvo para estudar offline.'
                : 'Material removido do offline.',
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: AppColors.onSecondary,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppText.sora(14, height: 20),
        ),
        icon: Icon(
          _savedOffline ? Icons.offline_pin_outlined : Icons.download_rounded,
          size: 16,
        ),
        label: Text(
            _savedOffline ? 'Salvo para offline' : 'Salvar para estudar offline'),
      ),
    );
  }

  Widget _relatedTile(RelatedItem item) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: () => showAppSnack(context, 'Abrindo "${item.title}"…'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.blueSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 16, color: AppColors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.manrope(13,
                            weight: FontWeight.w600,
                            color: AppColors.ink,
                            height: 19.5)),
                    Text(item.subtitle,
                        style: AppText.manrope(11, height: 16.5)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.radio_button_unchecked,
                  size: 16, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feedback() {
    return GestureDetector(
      onTap: () => showAppSnack(context, 'Obrigado! Vamos revisar este link.'),
      child: DashedBorderBox(
        color: const Color(0x6608348A),
        radius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.feedback_outlined,
                size: 20, color: AppColors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Link quebrado ou conteúdo desatualizado? ',
                  style: AppText.manrope(12, height: 16),
                  children: [
                    TextSpan(
                      text: 'Enviar feedback',
                      style: AppText.manrope(12,
                          weight: FontWeight.w700,
                          color: AppColors.orange,
                          height: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
