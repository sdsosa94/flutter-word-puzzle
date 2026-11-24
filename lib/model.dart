import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'model.g.dart';

abstract class Location implements Built<Location, LocationBuilder> {
  int get x;
  int get y;

  Location get left => leftOffset(1);
  Location get right => rightOffset(1);
  Location get up => upOffset(1);
  Location get down => downOffset(1);

  Location leftOffset(int offset) => Location.at(x - offset, y);
  Location rightOffset(int offset) => Location.at(x + offset, y);
  Location upOffset(int offset) => Location.at(x, y - offset);
  Location downOffset(int offset) => Location.at(x, y + offset);

  String prettyPrint() => '($x, $y)';

  Location._();
  factory Location([void Function(LocationBuilder) updates]) = _$Location;
  factory Location.at(int x, int y) => Location((b) => b
    ..x = x
    ..y = y);

  static Serializer<Location> get serializer => _$locationSerializer;
}

enum Direction {
  across,
  down;

  @override
  String toString() => name;
}

abstract class CrosswordWord
    implements Built<CrosswordWord, CrosswordWordBuilder> {
  String get word;
  Location get location;
  Direction get direction;

  CrosswordWord._();
  factory CrosswordWord([void Function(CrosswordWordBuilder) updates]) =
      _$CrosswordWord;

  factory CrosswordWord.word({
    required String word,
    required Location location,
    required Direction direction,
  }) =>
      CrosswordWord((b) => b
        ..word = word
        ..location.replace(location)
        ..direction = direction);

  static int locationComparator(CrosswordWord a, CrosswordWord b) {
    if (a.location.y != b.location.y) {
      return a.location.y.compareTo(b.location.y);
    }
    if (a.location.x != b.location.x) {
      return a.location.x.compareTo(b.location.x);
    }
    return a.direction.name.compareTo(b.direction.name);
  }

  static Serializer<CrosswordWord> get serializer => _$crosswordWordSerializer;
}

abstract class CrosswordCharacter
    implements Built<CrosswordCharacter, CrosswordCharacterBuilder> {
  String get character;
  CrosswordWord? get acrossWord;
  CrosswordWord? get downWord;

  CrosswordCharacter._();
  factory CrosswordCharacter([
    void Function(CrosswordCharacterBuilder) updates,
  ]) = _$CrosswordCharacter;

  factory CrosswordCharacter.character({
    required String character,
    CrosswordWord? acrossWord,
    CrosswordWord? downWord,
  }) =>
      CrosswordCharacter((b) => b
        ..character = character
        ..acrossWord = acrossWord != null ? acrossWord.toBuilder() : null
        ..downWord = downWord != null ? downWord.toBuilder() : null);

  static Serializer<CrosswordCharacter> get serializer =>
      _$crosswordCharacterSerializer;
}

abstract class Crossword implements Built<Crossword, CrosswordBuilder> {
  int get width;
  int get height;
  BuiltList<CrosswordWord> get words;
  BuiltMap<Location, CrosswordCharacter> get characters;

  Crossword._();
  factory Crossword([void Function(CrosswordBuilder) updates]) = _$Crossword;

  factory Crossword.crossword({
    required int width,
    required int height,
    BuiltList<CrosswordWord>? words,
  }) =>
      Crossword((b) => b
        ..width = width
        ..height = height
        ..words.replace(words ?? BuiltList<CrosswordWord>()));

  Crossword addWord({
    required Location location,
    required String word,
    required Direction direction,
  }) {
    return rebuild((b) => b.words.add(
          CrosswordWord.word(
            location: location,
            word: word,
            direction: direction,
          ),
        ));
  }

  @BuiltValueHook(finalizeBuilder: true)
  static void _fillCharacters(CrosswordBuilder b) {
    b.characters.clear();
    for (final word in b.words.build()) {
      for (var i = 0; i < word.word.length; i++) {
        final location = word.direction == Direction.across
            ? word.location.rightOffset(i)
            : word.location.downOffset(i);
        final char = word.word[i];
        final existing = b.characters[location];
        b.characters[location] = CrosswordCharacter.character(
          character: char,
          acrossWord:
              word.direction == Direction.across ? word : existing?.acrossWord,
          downWord:
              word.direction == Direction.down ? word : existing?.downWord,
        );
      }
    }
  }

  String prettyPrintCrossword() {
    final buffer = StringBuffer();
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final char = characters[Location.at(x, y)];
        buffer.write(char?.character ?? ' ');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  static Serializer<Crossword> get serializer => _$crosswordSerializer;
}

@SerializersFor([
  Location,
  Crossword,
  CrosswordWord,
  CrosswordCharacter,
])
final Serializers serializers = _$serializers;
