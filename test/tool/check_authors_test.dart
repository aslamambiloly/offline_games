import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/offline_games.dart';

void main() {
  group('Built-in Games Metadata Guard (C7 & C8)', () {
    test('all built-in games have valid authors, ids, and non-empty metadata',
        () {
      const games = GameCatalog.builtIn;
      final seenIds = <String>{};
      final snakeCasePattern = RegExp(r'^[a-z][a-z0-9_]*$');

      expect(games.isNotEmpty, isTrue,
          reason: 'GameCatalog.builtIn must not be empty.');

      for (final game in games) {
        final meta = game.meta;

        // ID checks
        expect(meta.id.isNotEmpty, isTrue,
            reason: 'Game ID must not be empty.');
        expect(snakeCasePattern.hasMatch(meta.id), isTrue,
            reason: 'Game ID "${meta.id}" must be lower_snake_case.');
        expect(seenIds.add(meta.id), isTrue,
            reason:
                'Duplicate game ID "${meta.id}" detected in GameCatalog.builtIn.');

        // Content checks
        expect(meta.title.trim().isNotEmpty, isTrue,
            reason: 'Game "${meta.id}" title must not be empty.');
        expect(meta.description.trim().isNotEmpty, isTrue,
            reason: 'Game "${meta.id}" description must not be empty.');

        // Author checks (Constitution C7)
        expect(meta.authors.isNotEmpty, isTrue,
            reason:
                'Game "${meta.id}" must specify at least one author in meta.authors.');
        for (final author in meta.authors) {
          expect(author.name.trim().isNotEmpty, isTrue,
              reason: 'Game "${meta.id}" author name must not be empty.');
        }

        // Validate method runs without exception
        expect(() => meta.validate(), returnsNormally);
      }
    });
  });
}
