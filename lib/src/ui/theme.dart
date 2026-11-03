import 'package:flutter/material.dart';

/// Theming options for the offline arcade cards, frames, and spinners,
/// defaulting to the authentic Vintage Screen Pixel Vectors aesthetic.
class OfflineGamesTheme extends ThemeExtension<OfflineGamesTheme> {
  /// Creates an [OfflineGamesTheme].
  const OfflineGamesTheme({
    this.primaryColor,
    this.cardColor,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.accentGradient,
  });

  /// Primary accent neon color (defaults to [Color(0xFF00F0FF)] neon cyan in dark mode).
  final Color? primaryColor;

  /// Card CRT background color (defaults to pure black [Color(0xFF000000)] in dark mode, pure white in light mode).
  final Color? cardColor;

  /// Background color for the arcade screens.
  /// Defaults to pure black [Color(0xFF000000)] in dark mode and pure white [Color(0xFFFFFFFF)] in light mode.
  final Color? backgroundColor;

  /// Corner radius for retro cards and frames.
  final BorderRadius borderRadius;

  /// Optional vibrant arcade gradient.
  final Gradient? accentGradient;

  /// Factory constructor for the authentic dark Vintage Pixel Vector theme.
  factory OfflineGamesTheme.dark({
    Color? primaryColor,
    Color? cardColor,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    Gradient? accentGradient,
  }) {
    return OfflineGamesTheme(
      primaryColor: primaryColor ?? const Color(0xFF00F0FF),
      cardColor: cardColor ?? const Color(0xFF000000),
      backgroundColor: backgroundColor ?? const Color(0xFF000000),
      borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(4)),
      accentGradient: accentGradient ??
          const LinearGradient(
            colors: [Color(0xFF00F0FF), Color(0xFF39FF14)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
    );
  }

  /// Factory constructor for the authentic light Vintage Pixel Vector theme.
  factory OfflineGamesTheme.light({
    Color? primaryColor,
    Color? cardColor,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    Gradient? accentGradient,
  }) {
    return OfflineGamesTheme(
      primaryColor: primaryColor ?? const Color(0xFF000000),
      cardColor: cardColor ?? const Color(0xFFFFFFFF),
      backgroundColor: backgroundColor ?? const Color(0xFFFFFFFF),
      borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(4)),
      accentGradient: accentGradient ??
          const LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF00A859)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
    );
  }

  /// Resolves the effective [OfflineGamesTheme] from the ambient [BuildContext].
  static OfflineGamesTheme of(BuildContext context) {
    final extension = Theme.of(context).extension<OfflineGamesTheme>();
    final isLight = Theme.of(context).brightness == Brightness.light;
    final defaultBg =
        isLight ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final defaultCard =
        isLight ? const Color(0xFFFFFFFF) : const Color(0xFF000000);

    if (extension != null) {
      return OfflineGamesTheme(
        primaryColor: extension.primaryColor ??
            (isLight ? const Color(0xFF0072B5) : const Color(0xFF00F0FF)),
        cardColor: extension.cardColor ?? defaultCard,
        backgroundColor: extension.backgroundColor ?? defaultBg,
        borderRadius: extension.borderRadius,
        accentGradient: extension.accentGradient,
      );
    }

    return OfflineGamesTheme(
      primaryColor:
          isLight ? const Color(0xFF0072B5) : const Color(0xFF00F0FF),
      cardColor: defaultCard,
      backgroundColor: defaultBg,
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      accentGradient: const LinearGradient(
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
  OfflineGamesTheme copyWith({
    Color? primaryColor,
    Color? cardColor,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    Gradient? accentGradient,
  }) {
    return OfflineGamesTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      cardColor: cardColor ?? this.cardColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      accentGradient: accentGradient ?? this.accentGradient,
    );
  }

  @override
  OfflineGamesTheme lerp(
    covariant ThemeExtension<OfflineGamesTheme>? other,
    double t,
  ) {
    if (other is! OfflineGamesTheme) return this;
    return OfflineGamesTheme(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t),
      cardColor: Color.lerp(cardColor, other.cardColor, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t) ??
          borderRadius,
      accentGradient: Gradient.lerp(accentGradient, other.accentGradient, t),
    );
  }
}
