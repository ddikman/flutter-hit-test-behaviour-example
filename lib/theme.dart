import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color tokens from the imported "HitTestBehavior Demo" Claude Design.
class AppColors {
  AppColors._();

  static const bg = Color(0xFFFAFAFA);
  static const accent = Color(0xFFEC3C1C);
  static const accentTint = Color(0xFFFFE9E6);
  static const ink = Color(0xFF1A1A1A);
  static const ink2 = Color(0xFF302E34);
  static const body = Color(0xFF696969);
  static const sub = Color(0xFF8F8F8F);
  static const desc = Color(0xFF787878);
  static const cardBorder = Color(0xFFEFEFEF);
  static const boxBg = Color(0xFFFFF0EE);
  static const boxBorder = Color(0xFFE2E2E2);
  static const tagBg = Color(0xFFF4F4F4);
  static const tagBorder = Color(0xFFEAEAEA);
  static const statusBorder = Color(0xFFE7E7E7);
  static const waitingDot = Color(0xFFCACACA);
  static const cardShadow = Color.fromRGBO(20, 18, 24, 0.05);
  static const statusShadow = Color.fromRGBO(20, 18, 24, 0.06);
}

/// Inter — the body and heading font.
TextStyle inter(double size, FontWeight weight, Color color, {double? height, double? spacing}) =>
    GoogleFonts.inter(
        fontSize: size, fontWeight: weight, color: color, height: height, letterSpacing: spacing);

/// JetBrains Mono — for tags, code and timestamps.
TextStyle mono(double size, FontWeight weight, Color color, {double? spacing}) =>
    GoogleFonts.jetBrainsMono(
        fontSize: size, fontWeight: weight, color: color, letterSpacing: spacing);
