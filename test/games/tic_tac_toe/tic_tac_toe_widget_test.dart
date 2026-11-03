import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/offline_games.dart';

void main() {
  group('TicTacToe Widget', () {
    late ValueNotifier<bool> pausedNotifier;
    late List<int> reportedScores;

    setUp(() {
      pausedNotifier = ValueNotifier<bool>(false);
      reportedScores = <int>[];
    });

    tearDown(() {
      pausedNotifier.dispose();
    });

    testWidgets('tap flow: human taps cell 0, AI responds in another cell',
        (tester) async {
      const game = TicTacToeGame();
      final session = GameSession(
        bestScore: 5,
        paused: pausedNotifier,
        random: Random(42),
        reportScore: (score) => reportedScores.add(score),
        exit: () {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => game.build(context, session),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find cell at index 0 and tap
      final cell0 = find.byKey(const ValueKey('tic_tac_toe_cell_0'));
      expect(cell0, findsOneWidget);

      await tester.tap(cell0);
      await tester.pumpAndSettle();

      // Human placed X in cell 0
      expect(find.text('❌'), findsOneWidget);
      // AI placed O in one of the other cells
      expect(find.text('⭕'), findsOneWidget);
    });

    testWidgets('pause honoured: tapping cell when paused does nothing',
        (tester) async {
      const game = TicTacToeGame();
      pausedNotifier.value = true; // PAUSED

      final session = GameSession(
        bestScore: 5,
        paused: pausedNotifier,
        random: Random(42),
        reportScore: (score) => reportedScores.add(score),
        exit: () {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => game.build(context, session),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cell0 = find.byKey(const ValueKey('tic_tac_toe_cell_0'));
      await tester.tap(cell0);
      await tester.pumpAndSettle();

      // Cell 0 should still be empty because game is paused
      expect(find.text('❌'), findsNothing);
      expect(find.text('⭕'), findsNothing);
    });
  });
}
