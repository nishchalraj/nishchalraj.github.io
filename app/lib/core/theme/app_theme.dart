import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'breathing_tokens.dart';

class AppTheme {
  AppTheme._();

  static const _seed = Color(0xFFA78BFA);

  static const lightSurface     = Color(0xFFFAF7F2);
  static const lightSurfaceAlt  = Color(0xFFF2EEE6);
  static const lightInk         = Color(0xFF1E1B4B);
  static const lightInkSoft     = Color(0xFF3F3A6E);

  static const darkSurface      = Color(0xFF0F0E1F);
  static const darkSurfaceAlt   = Color(0xFF181631);
  static const darkInk          = Color(0xFFE9E7FF);
  static const darkInkSoft      = Color(0xFFB6B0DA);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark  => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    final cs = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: b,
      surface: isDark ? darkSurface : lightSurface,
      onSurface: isDark ? darkInk : lightInk,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
      textTheme: GoogleFonts.interTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).apply(
        bodyColor: cs.onSurface,
        displayColor: cs.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 20,
          letterSpacing: -0.4,
          fontWeight: FontWeight.w500,
          color: cs.onSurface,
        ),
        iconTheme: IconThemeData(color: cs.onSurface),
      ),
      cardTheme: CardThemeData(
        color: isDark ? darkSurfaceAlt.withValues(alpha: 0.6) : lightSurfaceAlt.withValues(alpha: 0.7),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 15),
        ),
      ),
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: _SlideFadeTransitions(),
        TargetPlatform.iOS:     _SlideFadeTransitions(),
      }),
    );

    return base.copyWith(extensions: <ThemeExtension<dynamic>>[
      BreathingTokens.from(isDark: isDark),
      BreathingMotion.standard,
    ]);
  }
}

class _SlideFadeTransitions extends PageTransitionsBuilder {
  const _SlideFadeTransitions();
  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
      .chain(CurveTween(curve: Curves.easeOutCubic))
      .animate(animation);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
