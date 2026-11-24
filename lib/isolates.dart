import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:built_collection/built_collection.dart';

import 'model.dart';
import 'utils.dart';

class _PlacementParams {
  final Crossword crossword;
  final List<String> words;
  final Location location;
  final Direction direction;
  final String? targetCharacter;

  const _PlacementParams({
    required this.crossword,
    required this.words,
    required this.location,
    required this.direction,
    this.targetCharacter,
  });
}

Crossword? _tryPlaceCandidateWords(_PlacementParams params) {
  final crossword = params.crossword;
  final location = params.location;
  final direction = params.direction;
  final targetChar = params.targetCharacter;

  for (final word in params.words) {
    if (targetChar != null) {
      for (var i = 0; i < word.length; i++) {
        if (word[i] == targetChar) {
          final startLoc = direction == Direction.across
              ? Location.at(location.x - i, location.y)
              : Location.at(location.x, location.y - i);
          final candidate = crossword.addWord(
            location: startLoc,
            word: word,
            direction: direction,
          );
          if (candidate != null) return candidate;
        }
      }
    } else {
      final candidate = crossword.addWord(
        location: location,
        word: word,
        direction: direction,
      );
      if (candidate != null) return candidate;
    }
  }

  return null;
}

Stream<Crossword> exploreCrosswordSolutions({
  required Crossword crossword,
  required BuiltSet<String> wordList,
}) async* {
  final stopwatch = Stopwatch()..start();
  var queue = WorkQueue.from(
    crossword: crossword,
    candidateWords: wordList,
    startLocation: Location.at(0, 0),
  );

  yield queue.crossword;

  final targetCells = (crossword.width * crossword.height * 0.8).floor();
  final random = Random();

  while (!queue.isCompleted && queue.crossword.characters.length < targetCells) {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final entries = queue.locationsToTry.entries.toList();
    final entry = entries[random.nextInt(entries.length)];
    final location = entry.key;
    final direction = entry.value;

    final List<String> wordsToTry;
    final String? targetChar;

    if (queue.crossword.words.isEmpty) {
      targetChar = null;
      final words = queue.candidateWords.toList()..shuffle(random);
      wordsToTry = words.take(1000).toList();
    } else {
      final char = queue.crossword.characters[location];
      if (char == null) {
        queue = queue.remove(location);
        continue;
      }
      targetChar = char.character;
      final matching = queue.candidateWords
          .where((word) => word.contains(targetChar!))
          .toList()
        ..shuffle(random);
      wordsToTry = matching.take(1000).toList();
    }

    if (wordsToTry.isEmpty) {
      queue = queue.remove(location);
      continue;
    }

    final nextCrossword = await compute(
      _tryPlaceCandidateWords,
      _PlacementParams(
        crossword: queue.crossword,
        words: wordsToTry,
        location: location,
        direction: direction,
        targetCharacter: targetChar,
      ),
    );

    if (nextCrossword != null) {
      queue = queue.updateFrom(nextCrossword);
      yield queue.crossword;
    } else {
      queue = queue.remove(location);
    }
  }

  stopwatch.stop();
  debugPrint('Total crossword generation time: ${stopwatch.elapsed.formatted}');
}
