import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../providers.dart';
import '../utils.dart';
import 'ticker_builder.dart';

class CrosswordInfoWidget extends ConsumerWidget {
  const CrosswordInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayInfo = ref.watch(displayInfoProvider);
    final startTime = ref.watch(startTimeProvider);
    final endTime = ref.watch(endTimeProvider);
    final remainingTime = ref.watch(expectedRemainingTimeProvider);

    return Card(
      elevation: 6,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TickerBuilder(
          builder: (context) {
            final elapsed = startTime != null
                ? (endTime ?? DateTime.now()).difference(startTime).formatted
                : '0ms';

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Crossword Info',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _row('Words in grid:', displayInfo.wordsInGridCount),
                _row('Candidate words:', displayInfo.candidateWordsCount),
                _row(
                  'Locations to explore:',
                  displayInfo.locationsToExploreCount,
                ),
                _row('Known bad locations:', displayInfo.knownBadLocationsCount),
                _row('Grid filled:', displayInfo.gridFilledPercentage),
                const Divider(),
                _row('Elapsed time:', elapsed),
                _row('Remaining time:', remainingTime.formatted),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
}
