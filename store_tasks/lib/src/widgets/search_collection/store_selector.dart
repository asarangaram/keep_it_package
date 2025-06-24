import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';
import 'package:store_tasks/src/widgets/search_collection/search_view.dart';

class StoreSelector extends ConsumerWidget {
  const StoreSelector({
    required this.onClose,
    super.key,
  });
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetStore = ref.watch(targetStoreProvider);
    return GetAvailableStores(
        loadingBuilder: () => CLLoader.widget(
              debugMessage: null,
              message: 'Scanning Avaliable Servers ...',
            ),
        errorBuilder: (e, st) {
          return Center(
            child: ShadBadge.destructive(
              onPressed: onClose,
              child: const Text('Failed to get server list'),
            ),
          );
        },
        builder: (stores) {
          if (!stores.contains(targetStore)) {
            return Center(
              child: ShadBadge.destructive(
                onPressed: onClose,
                child: const Text('Target Store Not found in list !!'),
              ),
            );
          }
          return ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 180),
            child: ShadSelect<CLStore>(
              placeholder: const Text('Select A Server'),
              padding: EdgeInsets.zero,
              initialValue: targetStore,
              options: [
                ...stores.map(
                    (e) => ShadOption(value: e, child: Text(e.store.identity))),
              ],
              selectedOptionBuilder: (context, value) {
                return Text(value.store.identity);
              },
              onChanged: (store) {
                if (store != null) {
                  ref.read(targetStoreProvider.notifier).state = store;
                }
              },
            ),
          );
        });
  }
}
