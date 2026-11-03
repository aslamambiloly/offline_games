import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/src/ui/retro_pixel_glyph.dart';

void main() {
  group('RetroPixelGlyph', () {
    testWidgets('renders each glyph without error', (tester) async {
      for (final type in PixelGlyphType.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: PixelGlyphWidget(
                  type: type,
                  pixelSize: 4,
                ),
              ),
            ),
          ),
        );
        expect(find.byType(PixelGlyphWidget), findsOneWidget);
        expect(find.bySemanticsLabel(type.semanticsLabel), findsOneWidget);
      }
    });
  });
}
