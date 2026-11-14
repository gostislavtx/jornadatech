import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/auth_repository.dart';
import '../data/catalog.dart';
import '../ui/app_tokens.dart';
import '../ui/app_widgets.dart';
import 'ajuda_page.dart';
import 'trilhas_page.dart';

/// Área logada: abas "Trilhas" e "Ajuda" + menu lateral (Perfil, Ajuda, Sair).
class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.user,
    this.trilhas = demoTrilhas,
    this.onLogout,
  });

  final AppUser user;
  final List<Trilha> trilhas;
  final VoidCallback? onLogout;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _tab = 0;

  /// Favoritos ficam aqui para não se perderem ao trocar de aba.
  final Set<String> _favorites = {};

  void _openMenu() => _scaffoldKey.currentState?.openEndDrawer();

  void _closeMenuThen(VoidCallback action) {
    _scaffoldKey.currentState?.closeEndDrawer();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        endDrawer: _MenuDrawer(
          onPerfil: () => _closeMenuThen(
              () => showAppSnack(context, 'Perfil: em breve.')),
          onAjuda: () => _closeMenuThen(() => setState(() => _tab = 1)),
          onSair: () => _closeMenuThen(() => widget.onLogout?.call()),
        ),
        body: IndexedStack(
          index: _tab,
          children: [
            TrilhasPage(
              user: widget.user,
              trilhas: widget.trilhas,
              favorites: _favorites,
              onToggleFavorite: (id) => setState(() {
                if (!_favorites.remove(id)) _favorites.add(id);
              }),
              onMenu: _openMenu,
            ),
            AjudaPage(user: widget.user, onMenu: _openMenu),
          ],
        ),
        bottomNavigationBar: _BottomNav(
          index: _tab,
          onSelect: (i) => setState(() => _tab = i),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _item(0, Icons.explore_outlined, 'Trilhas'),
              const SizedBox(width: 30),
              _item(1, Icons.support_outlined, 'Ajuda'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int i, IconData icon, String label) {
    final color = i == index ? AppColors.orange : AppColors.muted;
    return Semantics(
      selected: i == index,
      button: true,
      child: InkResponse(
        onTap: () => onSelect(i),
        radius: 36,
        // Sem largura/altura fixas: o rótulo não pode quebrar em duas linhas
        // (fonte maior, acessibilidade) e estourar o espaço.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 64, minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(height: 4),
                Text(label,
                    maxLines: 1,
                    softWrap: false,
                    style: AppText.manrope(10,
                        weight: FontWeight.w600, color: color, height: 15)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma "Menu": painel creme à direita.
class _MenuDrawer extends StatelessWidget {
  const _MenuDrawer({
    required this.onPerfil,
    required this.onAjuda,
    required this.onSair,
  });

  final VoidCallback onPerfil;
  final VoidCallback onAjuda;
  final VoidCallback onSair;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.68;
    return Drawer(
      width: width.clamp(220.0, 320.0),
      backgroundColor: AppColors.onPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                tooltip: 'Fechar menu',
                icon: const Icon(Icons.arrow_back_rounded,
                    size: 18, color: AppColors.ink),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              _entry('Perfil', onPerfil),
              _entry('Ajuda', onAjuda),
              _entry('Sair', onSair,
                  icon: Icons.logout_rounded, color: AppColors.orange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _entry(String label, VoidCallback onTap,
      {IconData? icon, Color color = AppColors.ink}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppText.sora(18, color: color, height: 24)),
          ],
        ),
      ),
    );
  }
}
