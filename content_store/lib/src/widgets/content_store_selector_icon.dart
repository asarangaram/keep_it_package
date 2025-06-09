import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shimmer/shimmer.dart';
import 'package:store/store.dart';

class ContentSourceSelectorIcon extends ConsumerWidget {
  const ContentSourceSelectorIcon({super.key});

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
            child: Column(
              children: [
                KnownServersList(
                  availableStores: widget.availableStores,
                ),
                const SearchServers()
              ],
            )),
        child: ShadButton.ghost(
          onPressed: popoverController.toggle,
          child: clIcons.connectToServer.iconFormatted(),
        ));
  }
}

class KnownServersList extends ConsumerWidget {
  const KnownServersList({
    required this.availableStores,
    super.key,
  });
  final RegisteredURLs availableStores;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadRadioGroupFormField<StoreURL>(
      items: availableStores.availableStores.map((serverURL) => GetStore(
          errorBuilder: (p0, p1) => Shimmer.fromColors(
                baseColor: Colors.grey[500]!,
                highlightColor: Colors.grey[800]!,
                child: ShadRadio(
                  value: serverURL,
                  label: Text(
                    serverURL.toString(),
                    style: ShadTheme.of(context)
                        .textTheme
                        .small
                        .copyWith(color: Colors.red),
                  ),
                  enabled: false,
                ),
              ),
          loadingBuilder: GreyShimmer.show, // Relace with loading widget
          storeURL: serverURL,
          builder: (store) {
            return ShadRadio(
              value: serverURL,
              enabled: store.store.isAlive,
              label: Text(
                serverURL.toString(),
                style: ShadTheme.of(context)
                    .textTheme
                    .small
                    .copyWith(color: store.store.isAlive ? null : Colors.red),
              ),
            );
          })),
      onChanged: (value) {
        if (value != null) {
          ref.read(registeredURLsProvider.notifier).activeStore = value;
        }
      },
      initialValue: availableStores.activeStoreURL,
    );
  }
}
