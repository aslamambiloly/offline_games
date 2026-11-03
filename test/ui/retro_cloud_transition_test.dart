import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/src/ui/retro_cloud_transition.dart';

void main() {
  group('RetroCloudSweep', () {
    testWidgets('triggers onMidpointReached and onComplete during sweep',
        (tester) async {
      var midpointCalled = false;
      var completeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                const Text('Underlying Game View'),
                RetroCloudSweep(
                  isSweeping: true,
                  duration: const Duration(milliseconds: 400),
                  onMidpointReached: () => midpointCalled = true,
                  onComplete: () => completeCalled = true,
                ),
              ],
            ),
          ),
        ),
      );

      // Initially at 0 progress
      expect(midpointCalled, isFalse);
      expect(completeCalled, isFalse);

      // Advance past midpoint (200ms)
      await tester.pump(const Duration(milliseconds: 250));
      expect(midpointCalled, isTrue);
      expect(completeCalled, isFalse);

      // Advance to completion
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(completeCalled, isTrue);
    });

    testWidgets('does not render clouds when isSweeping is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                RetroCloudSweep(
                  isSweeping: false,
                  onMidpointReached: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(RetroCloudSweep),
          matching: find.byType(CustomPaint),
        ),
        findsNothing,
      );
    });
  });
}
