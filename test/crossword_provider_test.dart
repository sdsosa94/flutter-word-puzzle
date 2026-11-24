import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generate_crossword/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Test workQueueProvider stream with real word list', () async {
    final container = ProviderContainer();
    final completer = Completer<void>();
    final stopwatch = Stopwatch()..start();
    var count = 0;

    container.listen(workQueueProvider, (previous, next) {
      count++;
      print('[$count] at ${stopwatch.elapsedMilliseconds}ms: state=$next');
      if (next.hasValue) {
        final wq = next.value!;
        print('    words=${wq.crossword.words.length}, chars=${wq.crossword.characters.length}');
        if (wq.crossword.words.length >= 2) {
          if (!completer.isCompleted) completer.complete();
        }
      }
    });

    await completer.future.timeout(const Duration(seconds: 15));
  });
}
