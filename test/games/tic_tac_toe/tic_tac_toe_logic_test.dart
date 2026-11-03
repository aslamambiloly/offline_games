import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/src/games/tic_tac_toe/logic/tic_tac_toe_ai.dart';
import 'package:offline_games/src/games/tic_tac_toe/logic/tic_tac_toe_state.dart';

void main() {
  group('TicTacToeState logic', () {
    test('initial state has empty board and human turn', () {
      final state = TicTacToeState.initial();
      expect(state.board.every((cell) => cell == BoardCell.empty), isTrue);
      expect(state.currentTurn, Player.x);
      expect(state.winner, isNull);
      expect(state.isDraw, isFalse);
      expect(state.isGameOver, isFalse);
    });

    test('valid move places cell and flips turn', () {
      final state = TicTacToeState.initial();
      final nextState = state.makeMove(0);

      expect(nextState.board[0], BoardCell.x);
      expect(nextState.currentTurn, Player.o);
    });

    test('invalid move into occupied cell throws or returns same state', () {
      final state = TicTacToeState.initial().makeMove(4);
      expect(() => state.makeMove(4), throwsArgumentError);
    });

    test('detects horizontal win', () {
      // X wins top row: 0, 1, 2
      var state = TicTacToeState.initial();
      state = state.makeMove(0); // X
      state = state.makeMove(3); // O
      state = state.makeMove(1); // X
      state = state.makeMove(4); // O
      state = state.makeMove(2); // X (wins top row)

      expect(state.winner, Player.x);
      expect(state.isGameOver, isTrue);
      expect(state.winningLine, equals([0, 1, 2]));
    });

    test('detects vertical win', () {
      // O wins middle col: 1, 4, 7
      var state = TicTacToeState.initial();
      state = state.makeMove(0); // X
      state = state.makeMove(1); // O
      state = state.makeMove(2); // X
      state = state.makeMove(4); // O
      state = state.makeMove(5); // X
      state = state.makeMove(7); // O (wins middle col)

      expect(state.winner, Player.o);
      expect(state.isGameOver, isTrue);
      expect(state.winningLine, equals([1, 4, 7]));
    });

    test('detects diagonal win', () {
      // X wins diagonal: 0, 4, 8
      var state = TicTacToeState.initial();
      state = state.makeMove(0); // X
      state = state.makeMove(1); // O
      state = state.makeMove(4); // X
      state = state.makeMove(2); // O
      state = state.makeMove(8); // X (wins diagonal)

      expect(state.winner, Player.x);
      expect(state.isGameOver, isTrue);
      expect(state.winningLine, equals([0, 4, 8]));
    });

    test('detects draw game', () {
      // Board:
      // X O X
      // X O O
      // O X X
      const cells = [
        BoardCell.x,
        BoardCell.o,
        BoardCell.x,
        BoardCell.x,
        BoardCell.o,
        BoardCell.o,
        BoardCell.o,
        BoardCell.x,
        BoardCell.x,
      ];
      const state = TicTacToeState(board: cells, currentTurn: Player.o);
      expect(state.winner, isNull);
      expect(state.isDraw, isTrue);
      expect(state.isGameOver, isTrue);
    });
  });

  group('TicTacToeAi (Minimax)', () {
    test('AI blocks human imminent win', () {
      // Human X: 0, 1 (threatening 2)
      // O must block at 2
      final board = [
        BoardCell.x,
        BoardCell.x,
        BoardCell.empty,
        BoardCell.o,
        BoardCell.empty,
        BoardCell.empty,
        BoardCell.empty,
        BoardCell.empty,
        BoardCell.empty,
      ];
      final state = TicTacToeState(board: board, currentTurn: Player.o);
      final bestMove = findBestMove(state, aiPlayer: Player.o);

      expect(bestMove, equals(2));
    });

    test('AI takes winning move over blocking', () {
      // O: 3, 4 (threatening 5 to win)
      // X: 0, 1 (threatening 2 to win)
      // O's turn: must play 5 to win immediately
      final board = [
        BoardCell.x,
        BoardCell.x,
        BoardCell.empty,
        BoardCell.o,
        BoardCell.o,
        BoardCell.empty,
        BoardCell.empty,
        BoardCell.empty,
        BoardCell.empty,
      ];
      final state = TicTacToeState(board: board, currentTurn: Player.o);
      final bestMove = findBestMove(state, aiPlayer: Player.o);

      expect(bestMove, equals(5));
    });

    test('Minimax AI NEVER loses against any random moves (50 simulations)',
        () {
      // Simulate 50 games where human plays randomly
      for (var seed = 0; seed < 50; seed++) {
        final random = Random(seed);
        var state = TicTacToeState.initial();

        while (!state.isGameOver) {
          if (state.currentTurn == Player.x) {
            // Random human move
            final emptyIndices = [
              for (var i = 0; i < 9; i++)
                if (state.board[i] == BoardCell.empty) i
            ];
            final humanMove = emptyIndices[random.nextInt(emptyIndices.length)];
            state = state.makeMove(humanMove);
          } else {
            // Minimax AI move
            final aiMove = findBestMove(state, aiPlayer: Player.o);
            state = state.makeMove(aiMove);
          }
        }

        // AI is Player.o: it can either Win or Draw, but NEVER lose!
        expect(state.winner, isNot(equals(Player.x)),
            reason: 'Minimax AI must never lose (seed $seed)');
      }
    });
  });
}
