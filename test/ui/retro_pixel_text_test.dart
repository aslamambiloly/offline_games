import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/src/ui/retro_pixel_text.dart';

void main() {
  group('RetroPixelText', () {
    testWidgets('renders pixel text with semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PixelText(
              'SCORE: 120',
              pixelSize: 2,
              color: Colors.green,
            ),
          ),
        ),
      );

      expect(find.byType(PixelText), findsOneWidget);
      expect(find.text('SCORE: 120'), findsOneWidget);
      expect(find.bySemanticsLabel('SCORE: 120'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('supports glow and custom sizing', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PixelText(
              'GAME OVER',
              pixelSize: 3,
              color: Colors.red,
              glowColor: Colors.redAccent,
            ),
          ),
        ),
      );

      expect(find.byType(PixelText), findsOneWidget);
      expect(find.text('GAME OVER'), findsOneWidget);
      expect(find.bySemanticsLabel('GAME OVER'), findsOneWidget);
      handle.dispose();
    });

    test('wrapText splits long text into lines matching maxWidth', () {
      final lines = PixelText.wrapText(
        text: 'FLIP CARDS AND MATCH EMOJI PAIRS WITH FEWEST MOVES',
        maxWidth: 150,
        pixelSize: 1.5,
        letterSpacing: 2.0,
      );

      expect(lines.length, greaterThan(1));
      for (final line in lines) {
        final w = line.length * (5 * 1.5) + (line.length - 1) * 2.0;
        expect(w, lessThanOrEqualTo(150));
      }
    });
  });
}
