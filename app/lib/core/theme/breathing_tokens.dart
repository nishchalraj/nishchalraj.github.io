import 'package:flutter/material.dart';

/// Brand-specific design tokens beyond the standard ColorScheme.
@immutable
class BreathingTokens extends ThemeExtension<BreathingTokens> {
  const BreathingTokens({
    required this.inhale,
    required this.holdIn,
    required this.exhale,
    required this.holdOut,
    required this.orbGlow,
    required this.cardBorder,
    required this.shimmer,
  });

  final Color inhale;
  final Color holdIn;
  final Color exhale;
  final Color holdOut;
  final Color orbGlow;
  final Color cardBorder;
  final Color shimmer;

  factory BreathingTokens.from({required bool isDark}) {
    return BreathingTokens(
      inhale:    const Color(0xFFA78BFA),
      holdIn:    const Color(0xFFC4B5FD),
      exhale:    const Color(0xFF8B5CF6),
      holdOut:   const Color(0xFF7C3AED),
      orbGlow:   isDark ? const Color(0x55C4B5FD) : const Color(0x33A78BFA),
      cardBorder: isDark
          ? const Color(0x14FFFFFF)
          : const Color(0x14000000),
      shimmer: isDark ? const Color(0x22FFFFFF) : const Color(0x14000000),
    );
  }

  @override
  BreathingTokens copyWith({
    Color? inhale, Color? holdIn, Color? exhale, Color? holdOut,
    Color? orbGlow, Color? cardBorder, Color? shimmer,
  }) => BreathingTokens(
    inhale: inhale ?? this.inhale,
    holdIn: holdIn ?? this.holdIn,
    exhale: exhale ?? this.exhale,
    holdOut: holdOut ?? this.holdOut,
    orbGlow: orbGlow ?? this.orbGlow,
    cardBorder: cardBorder ?? this.cardBorder,
    shimmer: shimmer ?? this.shimmer,
  );

  @override
  BreathingTokens lerp(BreathingTokens? other, double t) {
    if (other == null) return this;
    return BreathingTokens(
      inhale:     Color.lerp(inhale,     other.inhale,     t)!,
      holdIn:     Color.lerp(holdIn,     other.holdIn,     t)!,
      exhale:     Color.lerp(exhale,     other.exhale,     t)!,
      holdOut:    Color.lerp(holdOut,    other.holdOut,    t)!,
      orbGlow:    Color.lerp(orbGlow,    other.orbGlow,    t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      shimmer:    Color.lerp(shimmer,    other.shimmer,    t)!,
    );
  }
}

@immutable
class BreathingMotion extends ThemeExtension<BreathingMotion> {
  const BreathingMotion({
    required this.fast,
    required this.base,
    required this.slow,
    required this.page,
  });

  final Duration fast;
  final Duration base;
  final Duration slow;
  final Duration page;

  static const standard = BreathingMotion(
    fast: Duration(milliseconds: 150),
    base: Duration(milliseconds: 250),
    slow: Duration(milliseconds: 450),
    page: Duration(milliseconds: 350),
  );

  @override
  BreathingMotion copyWith({Duration? fast, Duration? base, Duration? slow, Duration? page}) =>
      BreathingMotion(
        fast: fast ?? this.fast,
        base: base ?? this.base,
        slow: slow ?? this.slow,
        page: page ?? this.page,
      );

  @override
  BreathingMotion lerp(BreathingMotion? other, double t) => other ?? this;
}

extension BreathingTokensX on BuildContext {
  BreathingTokens get bt => Theme.of(this).extension<BreathingTokens>()!;
  BreathingMotion get bm => Theme.of(this).extension<BreathingMotion>()!;
}
