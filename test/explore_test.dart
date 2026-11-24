import 'package:flutter_test/flutter_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:generate_crossword/model.dart';
import 'package:generate_crossword/isolates.dart';

void main() {
  test('exploreCrosswordSolutions test', () async {
    final words = BuiltSet<String>(['cat', 'cup', 'apple', 'pie', 'egg', 'tea', 'ear']);
    final crossword = Crossword.crossword(width: 20, height: 11);

    final stream = exploreCrosswordSolutions(crossword: crossword, wordList: words);
    final list = await stream.take(3).toList();
    print('Yielded ${list.length} work queues');
    for (var i = 0; i < list.length; i++) {
      print('Queue $i words: ${list[i].crossword.words.length}, chars: ${list[i].crossword.characters.length}');
    }
  });
}
