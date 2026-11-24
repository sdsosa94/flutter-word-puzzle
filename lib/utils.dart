import 'dart:math';
import 'package:built_collection/built_collection.dart';

final _random = Random();

extension RandomElements<E> on BuiltSet<E> {
  E randomElement([Random? random]) {
    final r = random ?? _random;
    return elementAt(r.nextInt(length));
  }
}

extension DurationFormat on Duration {
  String get formatted {
    final record = (
      inHours,
      inMinutes.remainder(60),
      inSeconds.remainder(60),
      inMilliseconds.remainder(1000),
    );
    return switch (record) {
      (> 0, final m, final s, _) => '${inHours}h ${m}m ${s}s',
      (_, > 0, final s, _) => '${inMinutes}m ${s}s',
      (_, _, > 0, final ms) => '${inSeconds}s ${ms}ms',
      (_, _, _, final ms) => '${ms}ms',
    };
  }
}
