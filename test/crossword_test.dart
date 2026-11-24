import 'package:flutter_test/flutter_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:generate_crossword/model.dart';
import 'package:generate_crossword/isolates.dart';

void main() {
  test('Crossword constraints and addWord', () {
    var crossword = Crossword.crossword(width: 10, height: 10);
    expect(crossword.valid, isTrue);

    // Place first word "cat" across at (1, 1)
    final w1 = crossword.addWord(
      location: Location.at(1, 1),
      word: 'cat',
      direction: Direction.across,
    );
    expect(w1, isNotNull);
    expect(w1!.valid, isTrue);
    expect(w1.characters.length, equals(3));

    // Adding duplicate word should return null
    final dup = w1.addWord(
      location: Location.at(1, 1),
      word: 'cat',
      direction: Direction.down,
    );
    expect(dup, isNull);

    // Adding a non-overlapping word when words is not empty should return null
    final nonOverlap = w1.addWord(
      location: Location.at(5, 5),
      word: 'dog',
      direction: Direction.down,
    );
    expect(nonOverlap, isNull);

    // Adding conflicting character at intersection should return null
    // (1, 1) has 'c', trying to place 'dog' starting at (1, 1) with 'd'
    final conflict = w1.addWord(
      location: Location.at(1, 1),
      word: 'dog',
      direction: Direction.down,
    );
    expect(conflict, isNull);

    // Adding valid intersection: 'cup' down at (1, 1), 'c' matches!
    final w2 = w1.addWord(
      location: Location.at(1, 1),
      word: 'cup',
      direction: Direction.down,
    );
    expect(w2, isNotNull);
    expect(w2!.valid, isTrue);
    expect(w2.characters.length, equals(5)); // 'c', 'a', 't', 'u', 'p'
  });
}
