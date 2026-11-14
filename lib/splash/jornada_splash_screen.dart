import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'jornada_theme.dart';
import 'widgets/jornada_logo.dart';
import 'widgets/loading_bars.dart';

export 'jornada_theme.dart' show JornadaColors;
export 'widgets/jornada_logo.dart' show JornadaLogo;

/// Splash animado do JornadaTech (degradê azul-marinho → laranja).
///
/// Todos os elementos se movem: o fundo muda devagar e tem um brilho que
/// pulsa, o logo entra e depois flutua, a etiqueta se "fecha", o nome sobe
/// e recebe um brilho que passa, a frase aparece palavra por palavra, as
/// barrinhas pulsam e as reticências do carregamento andam.
///
/// Fica na tela pelo menos [minDuration] e até [initialize] terminar;
/// depois chama [onFinished] (normalmente para navegar ao login).
class JornadaSplashScreen extends StatefulWidget {
  const JornadaSplashScreen({
    super.key,
    this.minDuration = const Duration(milliseconds: 2200),
    this.initialize,
    this.onFinished,
  });

  final Duration minDuration;

  /// Carregamentos iniciais (sessão, trilhas, cache offline…).
  /// É chamado uma única vez.
  final Future<void> Function()? initialize;

  final VoidCallback? onFinished;

  @override
  State<JornadaSplashScreen> createState() => _JornadaSplashScreenState();
}

class _JornadaSplashScreenState extends State<JornadaSplashScreen>
    with TickerProviderStateMixin {
  static const _tagline =
      'Do aprendizado das aulas ao conteúdo aberto gratuito.';

  /// Entrada, uma vez (1,8 s).
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  /// Movimento contínuo depois da entrada (ciclo de 6 s).
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  late final Animation<double> _logo =
      _step(0, 0.40, const Cubic(0.2, 0.8, 0.2, 1));
  late final Animation<double> _eyebrow =
      _step(0.25, 0.60, Curves.easeOutCubic);
  late final Animation<double> _title =
      _step(0.32, 0.68, Curves.easeOutCubic);
  late final Animation<double> _bottom = _step(0.60, 1.0, Curves.easeOut);

  late final List<Animation<double>> _words = [
    for (final (i, _) in _tagline.split(' ').indexed)
      _step(0.42 + i * 0.04, 0.67 + i * 0.04, Curves.easeOutCubic),
  ];

  Animation<double> _step(double begin, double end, Curve curve) =>
      CurvedAnimation(parent: _intro, curve: Interval(begin, end, curve: curve));

  bool _reduceMotion = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _waitAndFinish();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_reduceMotion) {
      _intro.value = 1;
      _ambient.stop();
      _ambient.value = 0;
    } else if (!_started) {
      _intro.forward();
      _ambient.repeat();
    } else if (!_ambient.isAnimating) {
      _ambient.repeat();
    }
    _started = true;
  }

  Future<void> _waitAndFinish() async {
    final init = widget.initialize;
    try {
      await Future.wait<void>([
        Future<void>.delayed(widget.minDuration),
        if (init != null) init(),
      ]);
    } catch (error, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'jornadatech splash',
        context: ErrorDescription('durante a inicialização do app'),
      ));
    }
    if (!mounted) return;
    widget.onFinished?.call();
  }

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    super.dispose();
  }

  /// Onda de -1 a 1 que completa [cycles] voltas a cada ciclo de 6 s.
  double _wave(double cycles) =>
      math.sin(2 * math.pi * _ambient.value * cycles);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _background(),
            SafeArea(
              child: _FitOrScroll(
                padding: const EdgeInsets.fromLTRB(32, 48, 32, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    _logoBlock(),
                    const SizedBox(height: 28),
                    _eyebrowText(),
                    const SizedBox(height: 10),
                    _titleText(),
                    const SizedBox(height: 16),
                    _taglineWords(),
                    const Spacer(),
                    _loadingBlock(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Fundo: degradê que muda devagar + brilho que pulsa ----------

  Widget _background() {
    return AnimatedBuilder(
      animation: _ambient,
      builder: (context, _) {
        final drift = _wave(1);
        final glow = 0.5 + 0.5 * _wave(1);
        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.89 + 0.25 * drift, -1.02),
                  end: Alignment(0.89 - 0.25 * drift, 1.02),
                  colors: JornadaColors.brandGradient.colors,
                  stops: [0, 0.38, 0.66 + 0.04 * drift, 0.86, 1],
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, -0.28),
              child: FractionallySizedBox(
                widthFactor: 1.3,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Transform.scale(
                    scale: 0.9 + 0.15 * glow,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withAlpha(
                              ((0.10 + 0.08 * glow) * 255).round(),
                            ),
                            Colors.white.withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------- Logo: sobe, cresce e aparece; depois flutua ----------

  Widget _logoBlock() {
    return FadeTransition(
      opacity: _logo,
      child: AnimatedBuilder(
        animation: Listenable.merge([_logo, _ambient]),
        child: const Center(child: JornadaLogo(size: 136)),
        builder: (context, child) {
          final t = _logo.value;
          final float = 5 * _wave(2);
          return Transform.translate(
            offset: Offset(0, 12 * (1 - t) + float),
            child: Transform.scale(scale: 0.94 + 0.06 * t, child: child),
          );
        },
      ),
    );
  }

  // ---------- Etiqueta: as letras se aproximam enquanto aparece ----------

  Widget _eyebrowText() {
    return FadeTransition(
      opacity: _eyebrow,
      child: AnimatedBuilder(
        animation: _eyebrow,
        builder: (context, _) => Text(
          'CESUCA · METAMORFOSE',
          textAlign: TextAlign.center,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: TextStyle(
            fontFamily: kJornadaFont,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 12 * (0.45 - 0.27 * _eyebrow.value),
            color: const Color(0xD1FFFFFF),
          ),
        ),
      ),
    );
  }

  // ---------- Nome: sobe e recebe um brilho que atravessa ----------

  Widget _titleText() {
    return FadeTransition(
      opacity: _title,
      child: AnimatedBuilder(
        animation: Listenable.merge([_title, _ambient]),
        child: const Text(
          'JornadaTech',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: kJornadaFont,
            fontSize: 34,
            height: 1.1,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.34,
            color: Colors.white,
          ),
        ),
        builder: (context, child) {
          // O brilho passa na primeira metade de cada ciclo de 3 s.
          final phase = (_ambient.value * 2) % 1;
          final sweep = _reduceMotion ? -1.0 : -1 + 2 * (phase / 0.5);
          return Transform.translate(
            offset: Offset(0, 14 * (1 - _title.value)),
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (rect) => LinearGradient(
                colors: const [
                  Color(0xFFF1F3FF),
                  Color(0xFFFFFFFF),
                  Color(0xFFFFD9C2),
                  Color(0xFFFFFFFF),
                  Color(0xFFF1F3FF),
                ],
                stops: const [0.30, 0.44, 0.50, 0.56, 0.70],
                transform: _SlideGradient(sweep),
              ).createShader(rect),
              child: child,
            ),
          );
        },
      ),
    );
  }

  // ---------- Frase: palavra por palavra ----------

  Widget _taglineWords() {
    final words = _tagline.split(' ');
    return Semantics(
      label: _tagline,
      child: ExcludeSemantics(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 270),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 4.5,
              children: [
                for (var i = 0; i < words.length; i++)
                  FadeTransition(
                    opacity: _words[i],
                    child: AnimatedBuilder(
                      animation: _words[i],
                      child: Text(
                        words[i],
                        style: const TextStyle(
                          fontFamily: kJornadaFont,
                          fontSize: 16,
                          height: 1.45,
                          color: Color(0xE6FFFFFF),
                        ),
                      ),
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, 8 * (1 - _words[i].value)),
                        child: child,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Carregamento: barrinhas + reticências que andam ----------

  Widget _loadingBlock() {
    return FadeTransition(
      opacity: _bottom,
      child: AnimatedBuilder(
        animation: _bottom,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 10 * (1 - _bottom.value)),
          child: child,
        ),
        child: Column(
          children: [
            LoadingBars(
              colors: const [Colors.white, Colors.white, Colors.white],
              animate: !_reduceMotion,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Preparando suas trilhas', style: _labelStyle),
                // Largura fixa para o texto não "pular" quando os pontos mudam.
                SizedBox(
                  width: 18,
                  child: AnimatedBuilder(
                    animation: _ambient,
                    builder: (context, _) {
                      final count = _reduceMotion
                          ? 3
                          : (_ambient.value * 15).floor() % 4;
                      return Text(
                        '.' * count,
                        key: const ValueKey('loading-dots'),
                        style: _labelStyle,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const _labelStyle = TextStyle(
    fontFamily: kJornadaFont,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

/// Desloca um degradê horizontalmente por [dx] larguras.
class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.dx);

  final double dx;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * dx, 0, 0);
}

/// Ocupa a tela inteira quando cabe (os `Spacer` distribuem o espaço);
/// quando não cabe — tela pequena, paisagem, fonte grande — rola em vez
/// de estourar.
class _FitOrScroll extends StatelessWidget {
  const _FitOrScroll({required this.padding, required this.child});

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
