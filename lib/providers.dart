import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:built_collection/built_collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'model.dart' as model;
import 'utils.dart';

part 'providers.g.dart';

@riverpod
Future<BuiltSet<String>> wordList(Ref ref) async {
  final re = RegExp(r'^[a-z]+$');
  final words = await rootBundle.loadString('assets/words.txt');
  return const LineSplitter()
      .convert(words)
      .toBuiltSet()
      .rebuild(
        (b) => b
          ..map((word) => word.toLowerCase().trim())
          ..where((word) => word.length > 2)
          ..where((word) => re.hasMatch(word)),
      );
}

enum CrosswordSize {
  small(20, 11),
  medium(40, 22),
  large(80, 44),
  xlarge(160, 88),
  xxlarge(500, 500);

  const CrosswordSize(this.width, this.height);
  final int width;
  final int height;

  String get label => '$width x $height';
}

@Riverpod(keepAlive: true)
class Size extends _$Size {
  @override
  CrosswordSize build() => CrosswordSize.medium;

  void setSize(CrosswordSize size) {
    state = size;
  }
}

@riverpod
Stream<model.Crossword> crossword(Ref ref) async* {
  final size = ref.watch(sizeProvider);
  final words = await ref.watch(wordListProvider.future);
  var current =
      model.Crossword.crossword(width: size.width, height: size.height);
  yield current;

  final random = Random();
  final targetCells = (size.width * size.height * 0.8).floor();

  while (current.characters.length < targetCells) {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final word = words.randomElement(random);
    final direction =
        random.nextBool() ? model.Direction.across : model.Direction.down;
    final maxX = direction == model.Direction.across
        ? current.width - word.length
        : current.width - 1;
    final maxY = direction == model.Direction.down
        ? current.height - word.length
        : current.height - 1;

    if (maxX < 0 || maxY < 0) continue;

    final x = random.nextInt(maxX + 1);
    final y = random.nextInt(maxY + 1);
    final loc = model.Location.at(x, y);

    current = current.addWord(
      location: loc,
      word: word,
      direction: direction,
    );
    yield current;
  }
}
