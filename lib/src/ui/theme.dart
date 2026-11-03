import 'package:flutter/material.dart';

/// Theming options for the offline arcade cards, frames, and spinners.
class OfflineGamesTheme extends ThemeExtension<OfflineGamesTheme> {
  /// Creates an [OfflineGamesTheme].
  const OfflineGamesTheme({
    this.primaryColor,
    this.cardColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.accentGradient,
  });

  /// Primary accent color (defaults to [ColorScheme.primary] if null).
  final Color? primaryColor;

  /// Card background color (defaults to [ColorScheme.surfaceContainerHigh] or [ColorScheme.surface]).
  final Color? cardColor;

  /// Rounded corner radius for offer cards and dialogs.
  final BorderRadius borderRadius;

  /// Optional vibrant gradient for arcade headers and spin wheels.
  final Gradient? accentGradient;

  /// Resolves the effective [OfflineGamesTheme] from the ambient [BuildContext].
  static OfflineGamesTheme of(BuildContext context) {
    final extension = Theme.of(context).extension<OfflineGamesTheme>();
    if (extension != null) return extension;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return OfflineGamesTheme(
      primaryColor: theme.colorScheme.primary,
      cardColor: isDark ? const Color(0xFF1E1E2C) : theme.colorScheme.surface,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      accentGradient: LinearGradient(
        colors: [
          theme.colorScheme.primary,
          theme.colorScheme.tertiary,
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
