import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/offline_games.dart';

class FakeConnectivitySource implements ConnectivitySource {
  FakeConnectivitySource({bool initialOnline = true})
      : _isOnline = initialOnline {
    _controller = StreamController<bool>.broadcast();
  }

  bool _isOnline;
  late final StreamController<bool> _controller;

  @override
  Stream<bool> get onlineStream => _controller.stream;

  @override
  Future<bool> isOnline() async => _isOnline;

  void emit(bool online) {
    _isOnline = online;
    _controller.add(online);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

class TestDummyGame extends OfflineGame {
  const TestDummyGame();

  @override
  GameMeta get meta => const GameMeta(
        id: 'test_dummy',
        title: 'Dummy Game',
        emoji: '🎯',
        authors: [GameAuthor(name: 'Tester', github: 'tester')],
      );

  @override
  Widget build(BuildContext context, GameSession session) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Playing Dummy Game'),
          ValueListenableBuilder<bool>(
            valueListenable: session.paused,
            builder: (context, paused, _) =>
                Text(paused ? 'Game is Paused' : 'Game is Running'),
          ),
          ElevatedButton(
            onPressed: () => session.reportScore(100),
            child: const Text('Score 100'),
          ),
        ],
      ),
    );
  }
}

void main() {
  group('OfflineGames Widget & Host UI Shell', () {
    late FakeConnectivitySource fakeConnectivity;
    late OfflineGamesController controller;

    setUp(() {
      fakeConnectivity = FakeConnectivitySource(initialOnline: true);
      controller = OfflineGamesController();
    });

    tearDown(() {
      fakeConnectivity.dispose();
      controller.dispose();
    });

    Widget createTestApp({
      GamesMode mode = const GamesMode.single(TestDummyGame()),
      Duration delay = const Duration(milliseconds: 100),
    }) {
      return MaterialApp(
        builder: (context, child) => OfflineGames(
          connectivity: fakeConnectivity,
          controller: controller,
          games: const [TestDummyGame()],
          mode: mode,
          offlineDelay: delay,
          child: child!,
        ),
        home: const Scaffold(
          body: Center(child: Text('Host App Content')),
        ),
      );
    }

    testWidgets('shows host content when online', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Host App Content'), findsOneWidget);
      expect(find.text('SIGNAL LOST IN TIME'), findsNothing);
    });

    testWidgets(
        'auto-shows offer card when connection drops after offlineDelay',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Drop connection
      fakeConnectivity.emit(false);
      await tester.pump();
      // Should not show immediately due to delay
      expect(find.text('SIGNAL LOST IN TIME'), findsNothing);

      // Advance clock past delay (100ms)
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(find.text('SIGNAL LOST IN TIME'), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);
    });

    testWidgets('tapping Dismiss hides offer card for current episode',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      fakeConnectivity.emit(false);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      // Tap Dismiss
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      expect(find.text('SIGNAL LOST IN TIME'), findsNothing);
      expect(find.text('Host App Content'), findsOneWidget);
    });

    testWidgets('tapping Play opens the game frame', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      fakeConnectivity.emit(false);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      // Tap Play
      await tester.tap(find.text('Play'));
      await tester.pumpAndSettle();

      expect(find.text('Playing Dummy Game'), findsOneWidget);
    });

    testWidgets('controller.open() programmatically opens game UI',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Playing Dummy Game'), findsNothing);

      controller.open();
      await tester.pumpAndSettle();

      expect(find.text('Playing Dummy Game'), findsOneWidget);

      controller.close();
      await tester.pumpAndSettle();

      expect(find.text('Playing Dummy Game'), findsNothing);
    });

    testWidgets('connection returns while playing shows back-online prompt',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      fakeConnectivity.emit(false);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Play'));
      await tester.pumpAndSettle();

      expect(find.text('Playing Dummy Game'), findsOneWidget);
      expect(find.text("You're back online!"), findsNothing);

      // Connection restored!
      fakeConnectivity.emit(true);
      await tester.pumpAndSettle();

      expect(find.text("You're back online!"), findsOneWidget);
      expect(find.text('Keep playing'), findsOneWidget);
      expect(find.text('Back to app'), findsOneWidget);

      // Tapping Keep playing dismisses prompt but keeps player in game
      await tester.tap(find.text('Keep playing'));
      await tester.pumpAndSettle();

      expect(find.text("You're back online!"), findsNothing);
      expect(find.text('Playing Dummy Game'), findsOneWidget);
    });

    testWidgets('showGameCredits opens credits sheet with author info',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      controller.open();
      await tester.pumpAndSettle();

      final context = tester.element(find.text('Playing Dummy Game'));
      showGameCredits(context, const TestDummyGame().meta);
      await tester.pumpAndSettle();

      expect(find.text('Authors & Contributors'), findsOneWidget);
      expect(find.text('GitHub: @tester'), findsOneWidget);
    });

    testWidgets('back navigation exits game frame before host app',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      controller.open();
      await tester.pumpAndSettle();
      expect(find.text('Playing Dummy Game'), findsOneWidget);

      // Simulate system back button via tester.binding.handlePopRoute()
      final handled = await tester.binding.handlePopRoute();
      expect(handled, isTrue);
      await tester.pumpAndSettle();

      expect(find.text('Playing Dummy Game'), findsNothing);
      expect(find.text('Host App Content'), findsOneWidget);
    });

    testWidgets('showOfflineGames manually launches modal route',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showOfflineGames(
                  context,
                  connectivity: fakeConnectivity,
                  games: const [TestDummyGame()],
                  mode: const GamesMode.single(TestDummyGame()),
                ),
                child: const Text('Launch Arcade'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Launch Arcade'));
      await tester.pumpAndSettle();

      expect(find.text('Playing Dummy Game'), findsOneWidget);
    });

    testWidgets('debugForceOffline: true triggers offline simulation immediately',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => OfflineGames(
            connectivity: fakeConnectivity, // fakeConnectivity is initially online
            debugForceOffline: true,
            child: child!,
          ),
          home: const Scaffold(body: Text('Host App')),
        ),
      );
      await tester.pumpAndSettle();

      // Offer card should appear without turning off network or waiting for offlineDelay!
      expect(find.text('SIGNAL LOST IN TIME'), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);
    });

    testWidgets('custom backgroundColor is applied', (tester) async {
      const customBg = Color(0xFF123456);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => OfflineGames(
            connectivity: fakeConnectivity,
            backgroundColor: customBg,
            debugForceOffline: true,
            child: child!,
          ),
          home: const Scaffold(body: Text('Host App')),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Play to view arcade shell
      await tester.tap(find.text('Play'));
      await tester.pumpAndSettle();

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(OfflineGames),
          matching: find.byWidgetPredicate(
            (w) => w is Material && w.color == customBg,
          ),
        ),
      );
      expect(material.color, equals(customBg));
    });
  });
}
