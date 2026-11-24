import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../providers.dart';
import 'crossword_info_widget.dart';
import 'crossword_widget.dart';

class _EagerInitialization extends ConsumerWidget {
  const _EagerInitialization({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(wordListProvider);
    ref.watch(workQueueProvider);
    return child;
  }
}

class CrosswordGeneratorApp extends ConsumerWidget {
  const CrosswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showDisplayInfo = ref.watch(showDisplayInfoProvider);

    return _EagerInitialization(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crossword Generator'),
          actions: const [
            _CrosswordGeneratorMenu(),
          ],
        ),
        body: Stack(
          children: [
            const CrosswordWidget(),
            if (showDisplayInfo)
              const Positioned(
                top: 16,
                right: 16,
                child: CrosswordInfoWidget(),
              ),
          ],
        ),
      ),
    );
  }
}

class _CrosswordGeneratorMenu extends ConsumerWidget {
  const _CrosswordGeneratorMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSize = ref.watch(sizeProvider);
    final showDisplayInfo = ref.watch(showDisplayInfoProvider);

    return MenuAnchor(
      builder: (context, controller, child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.more_vert),
          tooltip: 'Grid Options',
        );
      },
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            ref.read(showDisplayInfoProvider.notifier).toggle();
          },
          leadingIcon: showDisplayInfo
              ? const Icon(Icons.check_box, size: 18)
              : const Icon(Icons.check_box_outline_blank, size: 18),
          child: const Text('Display Info'),
        ),
        ...CrosswordSize.values.map((size) {
          return MenuItemButton(
            onPressed: () {
              ref.read(sizeProvider.notifier).setSize(size);
            },
            leadingIcon: size == currentSize
                ? const Icon(Icons.check, size: 18)
                : const SizedBox(width: 18),
            child: Text('${size.name} (${size.label})'),
          );
        }),
      ],
    );
  }
}
