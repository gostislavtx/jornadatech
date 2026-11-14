import 'package:flutter/material.dart';

/// Tokens do Figma "JornadaTech" (telas de login, home, material e ajuda).
///
/// O splash continua com as próprias cores em `splash/jornada_theme.dart`.
class AppColors {
  AppColors._();

  static const blue = Color(0xFF08348A); // brand/blue
  static const blueSoft = Color(0xFFD9EAFF); // brand/blue-soft
  static const orange = Color(0xFFEA4A00); // brand/orange
  static const orangeSoft = Color(0xFFFFE3CC); // brand/orange-soft
  static const accentInk = Color(0xFF921300); // accent/foreground
  static const ink = Color(0xFF090D14); // brand/ink
  static const text = Color(0xFF0C121A); // popover/foreground
  static const muted = Color(0xFF5E6A7B); // muted/foreground
  static const mutedBg = Color(0xFFECF1F5); // muted
  static const border = Color(0xFFDAE0E8); // input
  static const background = Color(0xFFFAF8F5); // background
  static const onPrimary = Color(0xFFFFFAF5); // primary/foreground
  static const onSecondary = Color(0xFFF6F9FC); // secondary/foreground
  static const favoriteBg = Color(0xFFFDE68A);
  static const favoriteStar = Color(0xFFD97706);

  /// Degradê azul → laranja usado nos cabeçalhos (136°).
  static const headerGradient = LinearGradient(
    begin: Alignment(-0.69, -0.72),
    end: Alignment(0.69, 0.72),
    colors: [blue, orange],
  );

  static const cardShadow = [
    BoxShadow(
      color: Color(0x6608348A),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -14,
    ),
  ];
}

const kSora = 'Sora';
const kManrope = 'Manrope';

/// Estilos de texto do Figma (Sora para títulos, Manrope para o resto).
class AppText {
  AppText._();

  static TextStyle sora(
    double size, {
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: kSora,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height == null ? null : height / size,
        letterSpacing: letterSpacing,
      );

  static TextStyle manrope(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.muted,
    double? height,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: kManrope,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height == null ? null : height / size,
        letterSpacing: letterSpacing,
      );

  /// Rótulo em maiúsculas (ex.: "NOME COMPLETO", "MEU PROGRESSO").
  static TextStyle label({Color color = AppColors.muted}) => manrope(
        12,
        weight: FontWeight.w600,
        color: color,
        height: 16,
        letterSpacing: 0.6,
      );

  /// Sobretítulo azul dos cards (ex.: "METAMORFOSE · MÓDULO 2").
  static TextStyle eyebrow() => manrope(
        11,
        weight: FontWeight.w600,
        color: AppColors.blue,
        height: 16.5,
        letterSpacing: 0.55,
      );
}
