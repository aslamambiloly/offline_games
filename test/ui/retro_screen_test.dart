import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/src/ui/retro_screen.dart';

void main() {
  group('RetroScreen UI Components', () {
    testWidgets('RetroPixelCard renders child and border', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RetroPixelCard(
              child: Text('ARCADE CARD'),
            ),
          ),
        ),
      );

      expect(find.text('ARCADE CARD'), findsOneWidget);
    });

    testWidgets('RetroPixelButton invokes onPressed on tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RetroPixelButton(
                label: 'SPIN',
                onPressed: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('SPIN'), findsOneWidget);
      await tester.tap(find.byType(RetroPixelButton));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('CrtScanlinesOverlay paints without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CrtScanlinesOverlay(
              child: Text('SCREEN CONTENT'),
            ),
          ),
        ),
      );

      expect(find.text('SCREEN CONTENT'), findsOneWidget);
      expect(find.byType(CrtScanlinesOverlay), findsOneWidget);
    });
  });
}
