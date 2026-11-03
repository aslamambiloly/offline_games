import 'package:flutter/material.dart';

/// Theming options for the offline arcade cards, frames, and spinners,
/// defaulting to the authentic Vintage Screen Pixel Vectors aesthetic.
class OfflineGamesTheme extends ThemeExtension<OfflineGamesTheme> {
  /// Creates an [OfflineGamesTheme].
  const OfflineGamesTheme({
    this.primaryColor,
    this.cardColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.accentGradient,
  });

  /// Primary accent neon color (defaults to [Color(0xFF00F0FF)] neon cyan).
  final Color? primaryColor;

  /// Card CRT background color (defaults to [Color(0xFF0D101C)]).
  final Color? cardColor;

  /// Corner radius for retro cards and frames.
  final BorderRadius borderRadius;

  /// Optional vibrant arcade gradient.
  final Gradient? accentGradient;

  /// Resolves the effective [OfflineGamesTheme] from the ambient [BuildContext].
  static OfflineGamesTheme of(BuildContext context) {
    final extension = Theme.of(context).extension<OfflineGamesTheme>();
    if (extension != null) return extension;

    return const OfflineGamesTheme(
      primaryColor: Color(0xFF00F0FF),
      cardColor: Color(0xFF0D101C),
      borderRadius: BorderRadius.all(Radius.circular(4)),
      accentGradient: LinearGradient(
        colors: [
          Color(0xFF00F0FF),
          Color(0xFF39FF14),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  @override
  ThemeExtension<OfflineGamesTheme> copyWith({
    Color? primaryColor,
    Color? cardColor,
    BorderRadius? borderRadius,
    Gradient? accentGradient,
  }) {
    return OfflineGamesTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      cardColor: cardColor ?? this.cardColor,
      borderRadius: borderRadius ?? this.borderRadius,
      accentGradient: accentGradient ?? this.accentGradient,
    );
  }

  @override
  ThemeExtension<OfflineGamesTheme> lerp(
    covariant ThemeExtension<OfflineGamesTheme>? other,
    double t,
  ) {
    if (other is! OfflineGamesTheme) return this;
    return OfflineGamesTheme(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t),
      cardColor: Color.lerp(cardColor, other.cardColor, t),
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t) ??
          borderRadius,
      accentGradient: Gradient.lerp(accentGradient, other.accentGradient, t),
    );
  }
}
