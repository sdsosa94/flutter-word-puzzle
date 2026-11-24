import 'package:flutter_test/flutter_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:generate_crossword/model.dart';
import 'package:generate_crossword/utils.dart';
import 'package:generate_crossword/isolates.dart';

void main() {
  test('DurationFormat formatted extension test', () {
    expect(const Duration(milliseconds: 350).formatted, equals('350ms'));
    expect(const Duration(seconds: 4, milliseconds: 200).formatted, equals('4s 200ms'));
    expect(const Duration(minutes: 2, seconds: 15).formatted, equals('2m 15s'));
    expect(const Duration(hours: 1, minutes: 5, seconds: 10).formatted, equals('1h 5m 10s'));
  });

  test('WorkQueue from, remove, and updateFrom test', () {
    final crossword = Crossword.crossword(width: 10, height: 10);
    final words = ['cat', 'apple', 'cup'];

    // 1. Initial empty crossword seeds (0, 0)
    final queue = WorkQueue.from(
      crossword: crossword,
      candidateWords: words,
      startLocation: Location.at(0, 0),
    );

    expect(queue.isCompleted, isFalse);
    expect(queue.locationsToTry.length, equals(1));
    expect(queue.locationsToTry[Location.at(0, 0)], equals(Direction.across));
    expect(queue.badLocations.isEmpty, isTrue);
    expect(queue.candidateWords.length, equals(3));

    // 2. Remove location
    final queueRemoved = queue.remove(Location.at(0, 0));
    expect(queueRemoved.locationsToTry.isEmpty, isTrue);
    expect(queueRemoved.badLocations.contains(Location.at(0, 0)), isTrue);
    expect(queueRemoved.isCompleted, isTrue);

    // 3. Update from crossword with 1 word
    final updatedCrossword = crossword.addWord(
      location: Location.at(0, 0),
      word: 'cat',
      direction: Direction.across,
    )!;

    final queueUpdated = queue.updateFrom(updatedCrossword);
    expect(queueUpdated.isCompleted, isFalse);
    expect(queueUpdated.candidateWords.contains('cat'), isFalse);
    expect(queueUpdated.candidateWords.length, equals(2));
    // The characters of 'cat' at (0, 0), (1, 0), (2, 0) should all be eligible for Direction.down
    expect(queueUpdated.locationsToTry.length, equals(3));
    expect(queueUpdated.locationsToTry[Location.at(0, 0)], equals(Direction.down));
    expect(queueUpdated.locationsToTry[Location.at(1, 0)], equals(Direction.down));
    expect(queueUpdated.locationsToTry[Location.at(2, 0)], equals(Direction.down));
  });

  test('exploreCrosswordSolutions using WorkQueue test', () async {
    final words = BuiltSet<String>(['cat', 'cup', 'apple', 'pie', 'egg', 'tea', 'ear']);
    final crossword = Crossword.crossword(width: 20, height: 11);

    final stream = exploreCrosswordSolutions(crossword: crossword, wordList: words);
    final results = await stream.take(3).toList();
    expect(results.length, equals(3));
    expect(results[0].crossword.words.length, equals(0));
    expect(results[1].crossword.words.length, greaterThanOrEqualTo(1));
  });
}
