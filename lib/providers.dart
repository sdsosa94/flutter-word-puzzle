import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:built_collection/built_collection.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'isolates.dart';
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

@Riverpod(keepAlive: true)
class StartTime extends _$StartTime {
  @override
  DateTime? build() => null;

  void set(DateTime? time) => state = time;
}

@Riverpod(keepAlive: true)
class EndTime extends _$EndTime {
  @override
  DateTime? build() => null;

  void set(DateTime? time) => state = time;
}

@Riverpod(keepAlive: true)
class ShowDisplayInfo extends _$ShowDisplayInfo {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool show) => state = show;
}

const _estimatedTotalCoverage = 0.54;

@riverpod
Duration expectedRemainingTime(Ref ref) {
  final size = ref.watch(sizeProvider);
  final startTime = ref.watch(startTimeProvider);
  final endTime = ref.watch(endTimeProvider);
  if (endTime != null || startTime == null) return Duration.zero;

  final workQueueAsync = ref.watch(workQueueProvider);
  final workQueue = workQueueAsync.value;
  if (workQueue == null) return Duration.zero;

  final filled = workQueue.crossword.characters.length;
  if (filled == 0) return Duration.zero;

  final totalCells = size.width * size.height;
  final estimatedTotalCells = totalCells * _estimatedTotalCoverage;
  if (filled >= estimatedTotalCells) return Duration.zero;

  final elapsed = DateTime.now().difference(startTime);
  final msPerCell = elapsed.inMilliseconds / filled;
  final remainingCells = estimatedTotalCells - filled;
  final remainingMs = (remainingCells * msPerCell).round();

  return Duration(milliseconds: remainingMs);
}

@riverpod
Stream<model.WorkQueue> workQueue(Ref ref) async* {
  final size = ref.watch(sizeProvider);
  final words = await ref.watch(wordListProvider.future);
  final initialCrossword =
      model.Crossword.crossword(width: size.width, height: size.height);

  Future.microtask(() {
    ref.read(startTimeProvider.notifier).set(DateTime.now());
    ref.read(endTimeProvider.notifier).set(null);
  });

  final stream = exploreCrosswordSolutions(
    crossword: initialCrossword,
    wordList: words,
  );

  await for (final queue in stream) {
    yield queue;
    if (queue.isCompleted) {
      Future.microtask(() {
        ref.read(endTimeProvider.notifier).set(DateTime.now());
      });
    }
  }

  Future.microtask(() {
    if (ref.read(endTimeProvider) == null) {
      ref.read(endTimeProvider.notifier).set(DateTime.now());
    }
  });
}

@riverpod
class DisplayInfo extends _$DisplayInfo {
  @override
  model.DisplayInfo build() {
    return ref.watch(
      workQueueProvider.select(
        (asyncQueue) => asyncQueue.when(
          data: (workQueue) => model.DisplayInfo.from(workQueue: workQueue),
          error: (_, _) => model.DisplayInfo.empty,
          loading: () => model.DisplayInfo.empty,
        ),
      ),
    );
  }
}
