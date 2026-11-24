import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:built_collection/built_collection.dart';
import 'package:generate_crossword/model.dart';
import 'package:generate_crossword/providers.dart';
import 'package:generate_crossword/widgets/crossword_widget.dart';

void main() {
  testWidgets('CrosswordWidget displays characters in cells', (tester) async {
    final crossword = Crossword.crossword(width: 5, height: 5).addWord(
      location: Location.at(1, 1),
      word: 'cat',
      direction: Direction.across,
    )!;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          crosswordProvider.overrideWith((ref) => Stream.value(crossword)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CrosswordWidget(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify 'C', 'A', 'T' are displayed on screen
    expect(find.text('C'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('T'), findsOneWidget);
  });
}
