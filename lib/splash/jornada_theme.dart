import 'package:flutter/painting.dart';

/// Cores da identidade JornadaTech usadas no splash.
class JornadaColors {
  JornadaColors._();

  static const navy = Color(0xFF16287A);
  static const navyMid = Color(0xFF24307E);
  static const plum = Color(0xFF6A3C6A);
  static const rust = Color(0xFFB04A26);
  static const orangeDeep = Color(0xFFC2410C);
  static const orange = Color(0xFFE8590C);
  static const blue = Color(0xFF1E3AA8);
  static const ground = Color(0xFFF8F6F2);
  static const odsChip = Color(0xFFDFE7FB);

  /// Degradê azul-marinho → laranja (equivalente ao `158deg` do protótipo).
  static const brandGradient = LinearGradient(
    begin: Alignment(-0.89, -1.02),
    end: Alignment(0.89, 1.02),
    colors: [navy, navyMid, plum, rust, orangeDeep],
    stops: [0, 0.38, 0.66, 0.86, 1],
  );
}

class JornadaAssets {
  JornadaAssets._();

  /// Fundo do ícone, sem barras, circuito nem texto.
  static const logoBase = AssetImage('assets/images/logo_base.png');

  /// Só o texto "Jornada Tech", com fundo transparente.
  static const logoText = AssetImage('assets/images/logo_text.png');
}

/// Família declarada no pubspec.yaml (assets/fonts/Sora-*.ttf).
const kJornadaFont = 'Sora';
