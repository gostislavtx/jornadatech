import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../jornada_theme.dart';

/// O ícone JornadaTech com as barras e o circuito animados.
///
/// O logo é montado em três camadas, no espaço original de 606 × 612 px:
/// o fundo do ícone (imagem), as barras e o circuito (desenhados em código,
/// por isso podem se mexer) e o texto "Jornada Tech" (imagem) por cima.
///
/// Animação: as barras sobem de trás do texto e depois "respiram" como um
/// gráfico ao vivo; as trilhas do circuito são desenhadas de baixo para cima
/// e, em seguida, pulsos de energia sobem por elas sem parar, do centro para
/// fora, acendendo cada nó quando chegam.
class JornadaLogo extends StatefulWidget {
  const JornadaLogo({
    super.key,
    this.size = 136,
    this.onDark = true,
    this.animate = true,
  });

  final double size;

  /// `true` sobre o degradê (sombra mais forte).
  final bool onDark;

  /// `false` mostra o logo pronto e parado.
  final bool animate;

  @override
  State<JornadaLogo> createState() => _JornadaLogoState();
}

class _JornadaLogoState extends State<JornadaLogo>
    with TickerProviderStateMixin {
  /// Montagem: barras e trilhas (2,4 s, uma vez). As trilhas só começam
  /// quando o logo já está visível no splash.
  late final AnimationController _build = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  /// Energia subindo pelo circuito e "respiração" das barras (ciclo de 2 s).
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );

  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = !widget.animate || MediaQuery.of(context).disableAnimations;
    if (still == _still && (_build.isAnimating || _build.value > 0)) return;
    _still = still;
    if (still) {
      _build.value = 1;
      _loop.stop();
      _loop.value = 0;
    } else {
      _build.forward();
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _build.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final radius = BorderRadius.circular(size * 0.235);
    return Semantics(
      label: 'Logo JornadaTech',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            widget.onDark
                ? const BoxShadow(
                    color: Color(0x73080E30),
                    offset: Offset(0, 18),
                    blurRadius: 40,
                  )
                : const BoxShadow(
                    color: Color(0x2916287A),
                    offset: Offset(0, 14),
                    blurRadius: 36,
                  ),
          ],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: widget.onDark
                ? const Color(0x2EFFFFFF)
                : const Color(0x1416287A),
          ),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox.fromSize(
              size: _LogoArt.canvas,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: JornadaAssets.logoBase,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                    excludeFromSemantics: true,
                  ),
                  CustomPaint(
                    key: const ValueKey('logo-art'),
                    painter: _LogoArtPainter(
                      build: _build,
                      loop: _loop,
                      still: _still,
                    ),
                  ),
                  Image(
                    image: JornadaAssets.logoText,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                    excludeFromSemantics: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Geometria medida no logo original (606 × 612 px)
// ---------------------------------------------------------------------

const _logoBlue = Color(0xFF1730A6);
const _logoOrange = Color(0xFFDC5A0D);
/// Cor da energia que sobe pelo circuito (âmbar, aparece bem no fundo branco).
const _logoEnergy = Color(0xFFFFC440);
const _logoEnergyHot = Color(0xFFFFFAEB);
const _logoNodeLit = Color(0xFFFFA62E);

class _Bar {
  const _Bar(this.color, this.x0, this.x1, this.top, this.bottom);

  final Color color;
  final double x0, x1, top;

  /// Contorno de baixo, da esquerda para a direita (é recortado pelo texto).
  final List<Offset> bottom;

  double get lowest => bottom.map((p) => p.dy).reduce(math.max);

  Path get path {
    const r = 3.0;
    final p = Path()
      ..moveTo(x0, top + r)
      ..quadraticBezierTo(x0, top, x0 + r, top)
      ..lineTo(x1 - r, top)
      ..quadraticBezierTo(x1, top, x1, top + r);
    for (final pt in bottom.reversed) {
      p.lineTo(pt.dx, pt.dy);
    }
    return p..close();
  }
}

class _LogoArt {
  _LogoArt._();

  static const canvas = Size(606, 612);

  static const bars = [
    _Bar(_logoBlue, 166.0, 229.0, 166.0, [Offset(166.0, 283.4), Offset(173.0, 282.7), Offset(180.0, 281.9), Offset(187.0, 280.8), Offset(194.0, 279.4), Offset(201.0, 277.8), Offset(208.0, 276.0), Offset(215.0, 273.9), Offset(222.0, 271.5), Offset(229.0, 268.9)]),
    _Bar(_logoOrange, 266.0, 329.0, 92.0, [Offset(266.0, 266.8), Offset(273.0, 266.7), Offset(280.0, 266.9), Offset(287.0, 267.3), Offset(294.0, 267.9), Offset(301.0, 268.8), Offset(308.0, 270.0), Offset(315.0, 271.3), Offset(322.0, 273.0), Offset(329.0, 274.8)]),
    _Bar(_logoBlue, 366.0, 429.0, 16.0, [Offset(366.0, 273.5), Offset(373.0, 279.3), Offset(380.0, 283.7), Offset(387.0, 286.9), Offset(394.0, 288.6), Offset(401.0, 289.1), Offset(408.0, 288.2), Offset(415.0, 286.0), Offset(422.0, 282.4), Offset(429.0, 277.6)]),
  ];

  /// Trilhas, de baixo até o centro do nó.
  static const traces = <List<Offset>>[
    [Offset(226.5, 579), Offset(226.5, 529), Offset(151, 460)],
    [Offset(255, 579), Offset(255, 493), Offset(214, 452), Offset(209, 405)],
    [Offset(284, 579), Offset(284, 371)],
    [Offset(314, 579), Offset(314, 490), Offset(357, 445), Offset(368.5, 405)],
    [Offset(345.5, 579), Offset(345.5, 532), Offset(418, 467)],
  ];

  /// Ordem de montagem: o centro primeiro, depois as do meio e as de fora.
  static const traceOrder = [2, 1, 0, 1, 2];

  static const nodeRadius = 15.5;
  static const ringWidth = 13.0;
  static const traceWidth = 15.0;
}

class _LogoArtPainter extends CustomPainter {
  _LogoArtPainter({
    required this.build,
    required this.loop,
    required this.still,
  }) : super(repaint: Listenable.merge([build, loop]));

  final Animation<double> build;
  final Animation<double> loop;
  final bool still;

  static final List<Path> _tracePaths = [
    for (final t in _LogoArt.traces) _trimmedPath(t),
  ];

  /// O traço termina no meio do anel, para não aparecer dentro do furo.
  static Path _trimmedPath(List<Offset> pts) {
    final last = pts.last;
    final prev = pts[pts.length - 2];
    final dir = (last - prev) / (last - prev).distance;
    final end = last - dir * _LogoArt.nodeRadius;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1).take(pts.length - 2)) {
      path.lineTo(p.dx, p.dy);
    }
    return path..lineTo(end.dx, end.dy);
  }

  static double _interval(double t, double begin, double end,
      [Curve curve = Curves.linear]) {
    final x = ((t - begin) / (end - begin)).clamp(0.0, 1.0).toDouble();
    return curve.transform(x);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final b = build.value;
    final l = loop.value;
    final live = still ? 0.0 : _interval(b, 0.80, 1.0);

    // ---- Barras: sobem de trás do texto e depois "respiram" ----
    for (var i = 0; i < _LogoArt.bars.length; i++) {
      final bar = _LogoArt.bars[i];
      final grow = _interval(b, 0.04 + 0.10 * i, 0.38 + 0.10 * i,
          Curves.easeOutCubic);
      final breathe = 0.5 + 0.5 * math.sin(2 * math.pi * (l + i / 3));
      final height = bar.lowest - bar.top;
      final drop = height * (1 - grow) + height * 0.05 * breathe * live;
      final shape = bar.path;
      canvas.save();
      canvas.clipPath(shape);
      canvas.translate(0, drop);
      canvas.drawPath(shape, Paint()..color = bar.color);
      canvas.restore();
    }

    // ---- Circuito ----
    final trace = Paint()
      ..color = _logoOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = _LogoArt.traceWidth
      ..strokeJoin = StrokeJoin.round;

    for (var j = 0; j < _LogoArt.traces.length; j++) {
      final order = _LogoArt.traceOrder[j];
      final metric = _tracePaths[j].computeMetrics().first;

      // 1) Montagem: a trilha é desenhada de baixo para cima.
      final draw = _interval(b, 0.30 + 0.08 * order, 0.62 + 0.08 * order,
          Curves.easeInOutCubic);
      if (draw > 0) {
        canvas.drawPath(metric.extractPath(0, metric.length * draw), trace);
      }

      // Enquanto monta, a ponta da trilha brilha (a "corrente" chegando).
      if (draw > 0 && draw < 1) {
        _drawEnergy(canvas, metric, metric.length * draw, 1);
      }

      // 2) Depois de montado: pulsos de energia sobem de baixo para cima,
      //    do centro para fora, sem parar.
      final phase = (l - order * 0.12) % 1.0;
      if (live > 0 && phase < _travel) {
        final x = Curves.easeIn.transform(phase / _travel);
        final appear = (phase / (_travel * 0.15)).clamp(0.0, 1.0).toDouble();
        _drawEnergy(canvas, metric, metric.length * x, appear * live);
      }

      // 3) Nó: aparece quando a trilha chega e acende quando a energia chega.
      final pop = _interval(draw, 0.85, 1.0, Curves.easeOutBack);
      if (pop <= 0) continue;
      final flash = live * _flash(phase);
      final node = _LogoArt.traces[j].last;
      if (flash > 0.01) {
        canvas.drawCircle(
          node,
          _LogoArt.nodeRadius + _LogoArt.ringWidth / 2 + 6,
          Paint()
            ..color = _logoEnergy.withAlpha((200 * flash).round())
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
        );
      }
      canvas.drawCircle(
        node,
        _LogoArt.nodeRadius * pop,
        Paint()
          ..color = Color.lerp(_logoOrange, _logoNodeLit, flash)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = _LogoArt.ringWidth * pop,
      );
    }
  }

  /// Parte do ciclo em que a energia está subindo (o resto é o nó aceso).
  static const _travel = 0.62;

  /// Comprimento do rastro da energia, no espaço de 606 px do logo.
  static const _tail = 120.0;

  /// Rastro âmbar que some para trás + cabeça clara com brilho.
  static void _drawEnergy(
      Canvas canvas, ui.PathMetric metric, double head, double strength) {
    if (strength <= 0) return;
    const pieces = 10;
    for (var i = 0; i < pieces; i++) {
      final from = head - _tail + _tail * i / pieces;
      final to = head - _tail + _tail * (i + 1) / pieces;
      if (to <= 0) continue;
      final alpha = 255 * math.pow((i + 1) / pieces, 1.5) * strength;
      canvas.drawPath(
        metric.extractPath(math.max(0.0, from), to),
        Paint()
          ..color = _logoEnergy.withAlpha(alpha.round())
          ..style = PaintingStyle.stroke
          ..strokeWidth = _LogoArt.traceWidth
          ..strokeCap = StrokeCap.butt,
      );
    }
    final pos = metric.getTangentForOffset(head)?.position;
    if (pos == null) return;
    canvas.drawCircle(
      pos,
      20,
      Paint()
        ..color = _logoEnergy.withAlpha((200 * strength).round())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawCircle(
      pos,
      8,
      Paint()..color = _logoEnergyHot.withAlpha((255 * strength).round()),
    );
  }

  /// Brilho do nó: acende quando a energia chega e apaga devagar.
  static double _flash(double phase) {
    const start = _travel - 0.02;
    const end = 0.95;
    if (phase < start || phase > end) return 0;
    return math.sin(math.pi * (phase - start) / (end - start));
  }

  @override
  bool shouldRepaint(_LogoArtPainter old) =>
      old.build != build || old.loop != loop || old.still != still;
}
