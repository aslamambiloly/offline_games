import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/offline_games.dart';

void main() {
  test('generate GAMES.md gallery and update README.md', () {
    const games = GameCatalog.builtIn;

    final buffer = StringBuffer();
    buffer.writeln('# Built-in Games Gallery');
    buffer.writeln();
    buffer.writeln(
        'Here is the complete roster of mini-games currently bundled into `offline_games`. Every game is pure Dart/Flutter, fully offline, and proudly attributes its creator.');
    buffer.writeln();
    buffer.writeln('| Game | ID | Author(s) | Description |');
    buffer.writeln('|---|---|---|---|');

    for (final game in games) {
      final meta = game.meta;
      final authorsFormatted = meta.authors.map((a) {
        if (a.github != null && a.github!.isNotEmpty) {
          final handle = a.github!.replaceAll('@', '');
          return '[${a.name}](https://github.com/$handle)';
        } else if (a.url != null && a.url!.isNotEmpty) {
          return '[${a.name}](${a.url})';
        }
        return a.name;
      }).join(', ');

      buffer.writeln(
          '| **${meta.title}** | `${meta.id}` | $authorsFormatted | ${meta.description} |');
    }

    buffer.writeln();
    buffer.writeln(
        'Want to add your game here? Follow our simple [< 1 Hour Contribution Guide](doc/CONTRIBUTING_GAMES.md)!');
    buffer.writeln();

    final gamesMdFile = File('GAMES.md');
    gamesMdFile.writeAsStringSync(buffer.toString());
    stdout.writeln('✅ Generated GAMES.md with ${games.length} games.');

    // Also verify or update README.md
    final readmeFile = File('README.md');
    if (readmeFile.existsSync()) {
      var readmeContent = readmeFile.readAsStringSync();
      const tableStart = '<!-- GAMES_TABLE_START -->';
      const tableEnd = '<!-- GAMES_TABLE_END -->';

      final tableSnippet = StringBuffer();
      tableSnippet.writeln(tableStart);
      tableSnippet.writeln('| Game | ID | Author | Description |');
      tableSnippet.writeln('|---|---|---|---|');
      for (final game in games) {
        final meta = game.meta;
        final authorsFormatted = meta.authors.map((a) {
          if (a.github != null && a.github!.isNotEmpty) {
            final handle = a.github!.replaceAll('@', '');
            return '[${a.name}](https://github.com/$handle)';
          }
          return a.name;
        }).join(', ');
        tableSnippet.writeln(
            '| **${meta.title}** | `${meta.id}` | $authorsFormatted | ${meta.description} |');
      }
      tableSnippet.write(tableEnd);

      if (readmeContent.contains(tableStart) &&
          readmeContent.contains(tableEnd)) {
        final startIdx = readmeContent.indexOf(tableStart);
        final endIdx = readmeContent.indexOf(tableEnd) + tableEnd.length;
        readmeContent = readmeContent.replaceRange(
            startIdx, endIdx, tableSnippet.toString());
        readmeFile.writeAsStringSync(readmeContent);
        stdout.writeln('✅ Updated existing games table in README.md.');
      } else {
        // Append before Contributing Games section
        const contributingHeader = '## Contributing Games';
        if (readmeContent.contains(contributingHeader)) {
          final gallerySection =
              '## Built-in Games\n\n$tableSnippet\n\n---\n\n';
          readmeContent = readmeContent.replaceFirst(
            contributingHeader,
            '$gallerySection$contributingHeader',
          );
          readmeFile.writeAsStringSync(readmeContent);
          stdout.writeln(
              '✅ Inserted Built-in Games gallery section into README.md.');
        }
      }
    }
  });
}
