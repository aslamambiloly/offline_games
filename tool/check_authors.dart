import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/offline_games.dart';

void main() {
  test('built-in games have valid authors and metadata', () {
    const games = GameCatalog.builtIn;
    final seenIds = <String>{};
    final errors = <String>[];
    final snakeCasePattern = RegExp(r'^[a-z][a-z0-9_]*$');

    expect(games.isNotEmpty, isTrue,
        reason: 'GameCatalog.builtIn cannot be empty.');

    for (final game in games) {
      final meta = game.meta;

      // Validate ID
      if (meta.id.isEmpty) {
        errors.add('Game has an empty ID.');
      } else if (!snakeCasePattern.hasMatch(meta.id)) {
        errors.add('Game ID "${meta.id}" must be lower_snake_case.');
      } else if (!seenIds.add(meta.id)) {
        errors.add('Duplicate game ID found: "${meta.id}".');
      }

      // Validate Title & Description
      if (meta.title.trim().isEmpty) {
        errors.add('Game "${meta.id}" has an empty title.');
      }
      if (meta.description.trim().isEmpty) {
        errors.add('Game "${meta.id}" has an empty description.');
      }

      // Validate Authors (Mandatory per Constitution C7)
      if (meta.authors.isEmpty) {
        errors.add(
            'Game "${meta.id}" must have at least one author in meta.authors.');
      } else {
        for (final author in meta.authors) {
          if (author.name.trim().isEmpty) {
            errors.add(
                'Game "${meta.id}" contains an author with an empty name.');
          }
        }
      }

      // Validate meta constraints
      try {
        meta.validate();
      } catch (e) {
        errors.add('Game "${meta.id}" failed validation: $e');
      }
    }

    if (errors.isNotEmpty) {
      fail(
          'Author / Metadata check failed:\n${errors.map((e) => '  - $e').join('\n')}');
    }

    stdout.writeln(
        '✅ All ${games.length} built-in games passed author and metadata verification:');
    for (final game in games) {
      final authors = game.meta.authors.map((a) => a.name).join(', ');
      stdout.writeln('  • ${game.meta.title} (${game.meta.id}) by $authors');
    }
  });
}
