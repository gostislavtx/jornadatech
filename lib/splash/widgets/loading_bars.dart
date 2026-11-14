import 'dart:math' as math;

import 'package:flutter/material.dart';

/// As três barrinhas do logo pulsando, usadas como indicador de carregamento.
class LoadingBars extends StatefulWidget {
  const LoadingBars({
    super.key,
    required this.colors,
    this.animate = true,
  });

  /// Uma cor por barra, da menor para a maior.
  final List<Color> colors;

  /// Desligado quando o usuário pede para reduzir movimento.
  final bool animate;

  @override
  State<LoadingBars> createState() => _LoadingBarsState();
}

class _LoadingBarsState extends State<LoadingBars>
    with SingleTickerProviderStateMixin {
  static const _period = Duration(milliseconds: 1100);
  static const _heights = [14.0, 20.0, 26.0];
  // Atrasos de 0 s, 0,15 s e 0,3 s, como fração do ciclo.
  static const _delays = [0.0, 0.15 / 1.1, 0.30 / 1.1];

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: _period);

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(LoadingBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Escala vertical de 0,35 → 1 → 0,35 ao longo do ciclo.
  double _scaleFor(int index) {
    if (!widget.animate) return 1;
    final t = (_controller.value - _delays[index]) % 1.0;
    final wave = 0.5 - 0.5 * math.cos(2 * math.pi * t);
    return 0.35 + 0.65 * wave;
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.colors.length == 3, 'LoadingBars precisa de 3 cores');
    return Semantics(
      label: 'Carregando',
      child: SizedBox(
        height: 26,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 5),
                  child: Container(
                    width: 7,
                    height: _heights[i] * _scaleFor(i),
                    decoration: BoxDecoration(
                      color: widget.colors[i],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
