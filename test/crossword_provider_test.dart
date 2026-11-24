import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generate_crossword/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Test crosswordProvider stream with real word list', () async {
    final container = ProviderContainer();
    final completer = Completer<void>();
    final stopwatch = Stopwatch()..start();
    var count = 0;

    container.listen(crosswordProvider, (previous, next) {
      count++;
      print('[$count] at ${stopwatch.elapsedMilliseconds}ms: state=$next');
      if (next.hasValue) {
        final cw = next.value!;
        print('    words=${cw.words.length}, chars=${cw.characters.length}');
        if (cw.words.length >= 2) {
          if (!completer.isCompleted) completer.complete();
        }
      }
    });

    await completer.future.timeout(const Duration(seconds: 15));
  });
}
