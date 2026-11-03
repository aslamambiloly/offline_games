import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/src/storage/memory_score_store.dart';

void main() {
  group('MemoryScoreStore', () {
    late MemoryScoreStore store;

    setUp(() {
      store = MemoryScoreStore();
    });

    test('returns null for unrecorded game', () async {
      expect(await store.read('snake'), isNull);
    });

    test('stores and reads highest score', () async {
      await store.write('snake', 10);
      expect(await store.read('snake'), 10);

      // Higher score updates
      await store.write('snake', 25);
      expect(await store.read('snake'), 25);

      // Lower score does not overwrite best score
      await store.write('snake', 15);
      expect(await store.read('snake'), 25);
    });

    test('clears scores', () async {
      await store.write('snake', 50);
      store.clear();
      expect(await store.read('snake'), isNull);
    });
  });
}
