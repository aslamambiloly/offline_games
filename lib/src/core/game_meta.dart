import 'package:flutter/widgets.dart';
import 'author.dart';

/// Metadata describing an offline game.
class GameMeta {
  /// Creates a [GameMeta].
  const GameMeta({
    required this.id,
    required this.title,
    required this.emoji,
    required this.authors,
    this.description = '',
    this.version = '1.0.0',
    this.tags = const <String>[],
    this.iconBuilder,
  });

  /// Unique identifier in `lower_snake_case`, stable forever.
  final String id;

  /// Human-readable game title.
  final String title;

  /// Lightweight emoji representation (e.g. `🐍`, `❌`, `🃏`).
  final String emoji;

  /// List of authors (at least one author is required per Constitution rule C7).
  final List<GameAuthor> authors;

  /// Short description of the game rules or mechanics.
  final String description;

  /// Semantic version of the game.
  final String version;

  /// Optional tags describing the game type (e.g. `['arcade', 'puzzle']`).
  final List<String> tags;

  /// Optional custom icon widget builder.
  final Widget Function(BuildContext context)? iconBuilder;

  /// Validates that this metadata strictly satisfies the package constitution rules (C7).
  void validate() {
    if (authors.isEmpty) {
      throw AssertionError('Every game must declare at least one author (C7)');
    }
    final snakeCaseRegex = RegExp(r'^[a-z0-9_]+$');
    if (!snakeCaseRegex.hasMatch(id)) {
      throw AssertionError('Game id "$id" must be valid lower_snake_case');
    }
  }
}
