import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SourceSelection extends ConsumerWidget {
  const SourceSelection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetAvailableStores(
        errorBuilder: (_, __) => const SizedBox.shrink(),
        loadingBuilder: CircularProgressIndicator.new,
        builder: (availableStores) => SourceSelectionMenu(
              availableStores: availableStores,
              key: ValueKey(availableStores),
            ));
  }
}

class SourceSelectionMenu extends ConsumerStatefulWidget {
  const SourceSelectionMenu({required this.availableStores, super.key});
  final AvailableStores availableStores;

  @override
  ConsumerState<SourceSelectionMenu> createState() =>
      SourceSelectionMenuState();
}

class SourceSelectionMenuState extends ConsumerState<SourceSelectionMenu> {
  final popoverController = ShadPopoverController();

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadPopover(
        controller: popoverController,
        popover: (_) => SizedBox(
              width: 288,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.availableStores.availableStores
                      .map((e) => ListTile(
                            title: Text(
                              e.name,
                              style: ShadTheme.of(context)
                                  .textTheme
                                  .small
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ))
                      .toList()),
            ),
        child: ShadButton.ghost(
          onPressed: popoverController.toggle,
          child: clIcons.connectToServer.iconFormatted(),
        ));
  }
}
