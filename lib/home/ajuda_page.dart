import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../ui/app_tokens.dart';
import '../ui/app_widgets.dart';

/// Figma "Ajuda": como a trilha é montada + vídeo tutorial.
class AjudaPage extends StatelessWidget {
  const AjudaPage({super.key, required this.user, required this.onMenu});

  final AppUser user;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        GradientHeader(
          greeting: 'Suporte para você,',
          name: user.displayName,
          onMenu: onMenu,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Elaborando Sua Trilha',
                  style: AppText.sora(16, height: 24)),
              const SizedBox(height: 4),
              // O Figma tem "Lorem ipsum" aqui; este é um texto provisório
              // de verdade, para o grupo revisar.
              Text(
                'Cada trilha parte da ementa da sua disciplina no Cesuca ou no '
                'Metamorfose. Para cada unidade, a equipe escolhe poucos '
                'conteúdos abertos e gratuitos — vídeos, cursos e exercícios — '
                'que aprofundam o que foi visto em aula.\n\n'
                'Marque cada material como "Visto" ou "Concluído" para '
                'acompanhar seu progresso, salve os que quiser estudar sem '
                'internet e favorite as trilhas que você mais usa. Achou um '
                'link quebrado? Use "Enviar feedback" na tela do material.',
                style: AppText.manrope(12, height: 18),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Tutorial de Uso',
                        style: AppText.sora(16, height: 24)),
                    const SizedBox(height: 8),
                    _VideoPlaceholder(
                      height: 176,
                      onTap: () =>
                          showAppSnack(context, 'Vídeo tutorial: em breve.'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({required this.height, required this.onTap});

  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Assistir tutorial de uso',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          alignment: Alignment.center,
          child: const PlayBadge(),
        ),
      ),
    );
  }
}
