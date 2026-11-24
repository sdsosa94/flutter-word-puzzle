import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generate_crossword/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Test wordList loading', () async {
    final container = ProviderContainer();
    final stopwatch = Stopwatch()..start();
    try {
      final words = await container.read(wordListProvider.future);
      print('Loaded ${words.length} words in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e, st) {
      print('Error loading words: $e\n$st');
    }
  });
}
