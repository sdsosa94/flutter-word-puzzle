import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../providers.dart';

class _EagerInitialization extends ConsumerWidget {
  const _EagerInitialization({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(wordListProvider);
    return child;
  }
}

class CrosswordGeneratorApp extends StatelessWidget {
  const CrosswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return _EagerInitialization(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crossword Generator'),
        ),
        body: Consumer(
          builder: (context, ref, child) {
            final wordListAsync = ref.watch(wordListProvider);
            return wordListAsync.when(
              data: (words) {
                final wordList = words.toList();
                return ListView.builder(
                  itemCount: wordList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(wordList[index]),
                    );
                  },
                );
              },
              error: (error, stackTrace) => Center(
                child: Text('Error: $error'),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
}
