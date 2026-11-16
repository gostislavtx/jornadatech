import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../data/catalog.dart';
import '../ui/app_tokens.dart';
import '../ui/app_widgets.dart';

/// Tela 02 do Figma — Home: trilhas recomendadas, busca, filtros e favoritos.
class TrilhasPage extends StatefulWidget {
  const TrilhasPage({
    super.key,
    required this.user,
    required this.trilhas,
    required this.favorites,
    required this.onToggleFavorite,
    required this.onOpenTrilha,
    required this.onMenu,
    this.error = false,
    this.onRetry,
  });

  final AppUser user;

  /// `null` enquanto carrega do banco.
  final List<Trilha>? trilhas;
  final Set<String> favorites;
  final ValueChanged<String> onToggleFavorite;
  final ValueChanged<Trilha> onOpenTrilha;
  final VoidCallback onMenu;

  /// Falhou ao carregar (ex.: sem internet).
  final bool error;
  final VoidCallback? onRetry;

  @override
  State<TrilhasPage> createState() => _TrilhasPageState();
}

class _TrilhasPageState extends State<TrilhasPage> {
  final _searchCtrl = TextEditingController();
  final Set<TrilhaFilter> _filters = {};
  bool _showFilters = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Trilha> get _visible {
    final query = _normalize(_searchCtrl.text);
    return [
      for (final t in widget.trilhas ?? const <Trilha>[])
        if (_filters.every(t.tags.contains) &&
            (query.isEmpty ||
                _normalize('${t.title} ${t.origin}').contains(query)))
          t,
    ];
  }

  /// Minúsculas e sem acento, para "logica" achar "Lógica".
  static String _normalize(String s) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const to = 'aaaaaeeeeiiiiooooouuuuc';
    final lower = s.toLowerCase().trim();
    final out = StringBuffer();
    for (final ch in lower.split('')) {
      final i = from.indexOf(ch);
      out.write(i < 0 ? ch : to[i]);
    }
    return out.toString();
  }

  void _toggleFilter(TrilhaFilter? f) => setState(() {
        if (f == null) {
          _filters.clear(); // "Todos"
        } else if (!_filters.remove(f)) {
          _filters.add(f);
        }
      });

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: GradientHeader(
            greeting: 'Bom estudo,',
            name: widget.user.displayName,
            onMenu: widget.onMenu,
            bottom: _searchBox(),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          sliver: SliverList.list(
            children: [
              if (_showFilters) ...[_filtersBlock(), const SizedBox(height: 24)],
              Text('Suas trilhas recomendadas',
                  style: AppText.sora(16, height: 24)),
              Text('Curadoria feita a partir da sua ementa',
                  style: AppText.manrope(12, height: 16)),
              const SizedBox(height: 16),
              if (widget.error)
                _message(
                  'Não foi possível carregar as trilhas. Confira a internet.',
                  action: TextButton(
                    onPressed: widget.onRetry,
                    child: const Text('Tentar de novo'),
                  ),
                )
              else if (widget.trilhas == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.orange),
                  ),
                )
              else if (visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'Nenhuma trilha encontrada com esses filtros.',
                    textAlign: TextAlign.center,
                    style: AppText.manrope(14, height: 20),
                  ),
                ),
              for (final t in visible) ...[
                _TrilhaCard(
                  trilha: t,
                  favorite: widget.favorites.contains(t.id),
                  onToggleFavorite: () => widget.onToggleFavorite(t.id),
                  onOpen: () => widget.onOpenTrilha(t),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _message(String text, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(text,
              textAlign: TextAlign.center,
              style: AppText.manrope(14, height: 20)),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded, size: 16, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: const ValueKey('search'),
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              style: AppText.manrope(14, color: AppColors.text, height: 20),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'O que você quer aprofundar?',
                hintStyle: AppText.manrope(14, height: 20),
              ),
            ),
          ),
          IconButton(
            tooltip: _showFilters ? 'Esconder filtros' : 'Mostrar filtros',
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.tune_rounded,
              size: 16,
              color: _filters.isEmpty ? AppColors.orange : AppColors.blue,
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
    );
  }

  Widget _filtersBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.filter_alt_outlined,
                size: 16, color: AppColors.blue),
            const SizedBox(width: 8),
            Text('Filtros', style: AppText.sora(14, height: 20)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _chip('Todos', _filters.isEmpty, () => _toggleFilter(null)),
            for (final f in TrilhaFilter.values)
              _chip(f.label, _filters.contains(f), () => _toggleFilter(f)),
          ],
        ),
      ],
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.orange : Colors.white,
        shape: StadiumBorder(
          side: BorderSide(
              color: selected ? AppColors.orange : AppColors.border),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              style: selected
                  ? AppText.manrope(12,
                      weight: FontWeight.w600,
                      color: AppColors.onPrimary,
                      height: 16)
                  : AppText.manrope(12, weight: FontWeight.w500, height: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrilhaCard extends StatelessWidget {
  const _TrilhaCard({
    required this.trilha,
    required this.favorite,
    required this.onToggleFavorite,
    required this.onOpen,
  });

  final Trilha trilha;
  final bool favorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = trilha;
    return AppCard(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.origin.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.eyebrow()),
                    const SizedBox(height: 2),
                    Text(t.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sora(15, height: 22.5)),
                    const SizedBox(height: 2),
                    Text('${t.done} de ${t.total} aulas',
                        style: AppText.manrope(12, height: 16)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Semantics(
                button: true,
                toggled: favorite,
                label: favorite
                    ? 'Remover ${t.title} dos favoritos'
                    : 'Favoritar ${t.title}',
                child: InkWell(
                  key: ValueKey('fav-${t.id}'),
                  onTap: onToggleFavorite,
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: favorite
                          ? AppColors.favoriteBg
                          : AppColors.blueSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      favorite ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 22,
                      color:
                          favorite ? AppColors.favoriteStar : AppColors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: t.progress,
              minHeight: 6,
              backgroundColor: AppColors.mutedBg,
              color: AppColors.orange,
            ),
          ),
          const SizedBox(height: 7),
          Text('${t.percent}% concluído',
              style: AppText.manrope(11,
                  weight: FontWeight.w600,
                  color: AppColors.orange,
                  height: 16.5)),
        ],
      ),
    );
  }
}
