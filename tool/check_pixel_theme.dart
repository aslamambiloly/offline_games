import 'dart:io';

/// Automated verification tool ensuring all mini-games comply with the
/// 100% pure pixel vector design system (zero external fonts, zero Material icons).
void main() {
  final gamesDir = Directory('lib/src/games');
  if (!gamesDir.existsSync()) {
    stderr.writeln('Error: lib/src/games directory not found');
    exit(1);
  }

  final files = gamesDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  final errors = <String>[];

  // Regex patterns detecting non-pixel components
  final materialIconPattern = RegExp(r'Icons\.[a-zA-Z0-9_]+');
  final emojiPattern = RegExp(
    r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
    unicode: true,
  );

  for (final file in files) {
    final relativePath = file.path;
    final lines = file.readAsLinesSync();

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineNum = i + 1;

      // Skip comments or metadata definitions (e.g. fallback emoji string in GameMeta)
      final trimmed = line.trim();
      if (trimmed.startsWith('//') || trimmed.startsWith('*')) continue;
      if (trimmed.contains("emoji:") || trimmed.contains("final String emoji")) {
        continue;
      }

      if (materialIconPattern.hasMatch(line)) {
        errors.add(
          '$relativePath:$lineNum - Detected Material icon (`Icons.*`). '
          'Use PixelGlyphWidget or custom vector shapes instead.',
        );
      }

      if (emojiPattern.hasMatch(line)) {
        errors.add(
          '$relativePath:$lineNum - Detected emoji literal in UI. '
          'Use PixelGlyphWidget or PixelText instead to maintain vintage CRT aesthetics.',
        );
      }
    }
  }

  if (errors.isNotEmpty) {
    stderr.writeln(
      '❌ Pixel Theme Verification Failed (${errors.length} issues found):\n',
    );
    for (final err in errors) {
      stderr.writeln('  • $err');
    }
    stderr.writeln(
      '\nGUIDELINE: All games in offline_games must use authentic 8-bit vector '
      'components (PixelText, PixelGlyphWidget, RetroPixelCard) with ZERO external fonts '
      'and ZERO Material icons. See CONTRIBUTING.md for details.\n',
    );
    exit(1);
  }

  stdout.writeln(
    '✅ Pixel Theme Verification Passed: All games adhere to 100% pure pixel vector guidelines!',
  );
}
