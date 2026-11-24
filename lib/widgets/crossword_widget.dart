import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../model.dart';
import '../providers.dart';

class CrosswordWidget extends ConsumerWidget {
  const CrosswordWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = ref.watch(sizeProvider);
    return TableView.builder(
      columnCount: size.width,
      rowCount: size.height,
      columnBuilder: (column) => const TableSpan(
        extent: FixedTableSpanExtent(32),
      ),
      rowBuilder: (row) => const TableSpan(
        extent: FixedTableSpanExtent(32),
      ),
      cellBuilder: (context, vicinity) {
        final location = Location.at(vicinity.column, vicinity.row);
        return TableViewCell(
          child: Consumer(
            builder: (context, ref, child) {
              final character = ref.watch(
                workQueueProvider.select(
                  (asyncWorkQueue) =>
                      asyncWorkQueue.value?.crossword.characters[location]?.character,
                ),
              );
              return Container(
                decoration: BoxDecoration(
                  color: character != null
                      ? Colors.white
                      : Colors.blueGrey.shade50,
                  border: Border.all(color: Colors.blueGrey.shade200, width: 0.5),
                ),
                child: Center(
                  child: Text(
                    character?.toUpperCase() ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

