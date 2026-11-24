import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:built_collection/built_collection.dart';

import 'model.dart';
import 'utils.dart';

class _ExploreParams {
  final Crossword crossword;
  final BuiltSet<String> wordList;
  final int seed;

  const _ExploreParams({
    required this.crossword,
    required this.wordList,
    required this.seed,
  });
}

Crossword? _tryPlaceRandomWord(_ExploreParams params) {
  final crossword = params.crossword;
  final wordList = params.wordList;
  final random = Random(params.seed);

  if (crossword.words.isEmpty) {
    for (var attempt = 0; attempt < 100; attempt++) {
      final word = wordList.randomElement(random);
      final direction =
          random.nextBool() ? Direction.across : Direction.down;
      final maxX = direction == Direction.across
          ? crossword.width - word.length
          : crossword.width - 1;
      final maxY = direction == Direction.down
          ? crossword.height - word.length
          : crossword.height - 1;
      if (maxX < 0 || maxY < 0) continue;
      final x = random.nextInt(maxX + 1);
      final y = random.nextInt(maxY + 1);
      final candidate = crossword.addWord(
        location: Location.at(x, y),
        word: word,
        direction: direction,
      );
      if (candidate != null) return candidate;
    }
    return null;
  }

  final entries = crossword.characters.entries.toList();
  if (entries.isEmpty) return null;

  for (var attempt = 0; attempt < 1000; attempt++) {
    final entry = entries[random.nextInt(entries.length)];
    final char = entry.value.character;
    final loc = entry.key;

    final possibleDirections = <Direction>[];
    if (entry.value.acrossWord == null) {
      possibleDirections.add(Direction.across);
    }
    if (entry.value.downWord == null) {
      possibleDirections.add(Direction.down);
    }
    if (possibleDirections.isEmpty) continue;

    final direction =
        possibleDirections[random.nextInt(possibleDirections.length)];

    final word = wordList.randomElement(random);
    if (!word.contains(char)) continue;

    final matchingIndices = <int>[];
    for (var i = 0; i < word.length; i++) {
      if (word[i] == char) matchingIndices.add(i);
    }
    final charIndex = matchingIndices[random.nextInt(matchingIndices.length)];

    final startLoc = direction == Direction.across
        ? Location.at(loc.x - charIndex, loc.y)
        : Location.at(loc.x, loc.y - charIndex);

    final next = crossword.addWord(
      location: startLoc,
      word: word,
      direction: direction,
    );
    if (next != null) {
      return next;
    }
  }

  return null;
}

Stream<Crossword> exploreCrosswordSolutions({
  required Crossword crossword,
  required BuiltSet<String> wordList,
}) async* {
  var current = crossword;
  yield current;

  final targetCells = (current.width * current.height * 0.8).floor();
  final random = Random();

  while (current.characters.length < targetCells) {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final next = await compute(
      _tryPlaceRandomWord,
      _ExploreParams(
        crossword: current,
        wordList: wordList,
        seed: random.nextInt(1 << 31),
      ),
    );

    if (next != null) {
      current = next;
      yield current;
    }
  }
}
