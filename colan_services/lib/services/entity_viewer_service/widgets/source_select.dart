import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

class SourceSelection extends ConsumerWidget {
  const SourceSelection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetRegisterredURLs(
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
  final RegisteredURLs availableStores;

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
            child: ShadRadioGroupFormField<StoreURL>(
              items: widget.availableStores.availableStores
                  .map((server) => ShadRadio(
                        value: server,
                        label: Text(server.toString()),
                      )),
              onChanged: (value) {
                if (value != null) {
                  ref.read(registeredURLsProvider.notifier).activeStore = value;
                }
              },
              initialValue: widget.availableStores.activeStoreURL,
            )

            /* Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.availableStores.availableStores.map((e) {
                    return ListTile(
                      title: Text(
                        e.name.capitalizeFirstLetter(),
                        style: ShadTheme.of(context).textTheme.small.copyWith(
                            fontSize: widget.availableStores.isActiveStore(e)
                                ? 20
                                : 14,
                            fontWeight: widget.availableStores.isActiveStore(e)
                                ? FontWeight.bold
                                : null),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(e.scheme,
                            style: ShadTheme.of(context).textTheme.list),
                      ),
                      enabled: false,
                    );
                  }).toList()), */
            ),
        child: ShadButton.ghost(
          onPressed: popoverController.toggle,
          child: clIcons.connectToServer.iconFormatted(),
        ));
  }
}
