import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
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

    final queue = WorkQueue.from(
      crossword: crossword,
      candidateWords: ['apple'],
      startLocation: Location.at(0, 0),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workQueueProvider.overrideWith((ref) => Stream.value(queue)),
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
