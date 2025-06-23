import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';
import 'package:store_tasks/src/widgets/search_collection/create_new_collection.dart';

import '../pick_collection/wizard_error.dart';

class SearchView extends StatelessWidget {
  const SearchView(
      {required this.onFailed,
      required this.targetStore,
      required this.searchController,
      super.key});
  final CLStore targetStore;
  final VoidCallback onFailed;
  final SearchController searchController;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [targetStoreProvider.overrideWith((ref) => targetStore)],
      child: SearchView0(
        onFailed: onFailed,
        searchController: searchController,
      ),
    );
  }
}

class SearchView0 extends ConsumerWidget {
  const SearchView0({
    required this.onFailed,
    required this.searchController,
    super.key,
  });

  final VoidCallback onFailed;
  final SearchController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetStore = ref.watch(targetStoreProvider);
    return GetEntities(
        store: targetStore,
        isCollection: true,
        //isHidden: null,
        isDeleted: null,
        loadingBuilder: () => CLLoader.widget(debugMessage: null),
        errorBuilder: (e, st) => WizardError.show(context,
            e: e, st: st, onClose: () => searchController.closeView(null)),
        builder: (entries) {
          final List<ViewerEntity> items;
          if (searchController.text.isEmpty) {
            items = entries.entities;
          } else {
            items = entries.entities
                .where((item) => item.label!.startsWith(searchController.text))
                .toList();
          }
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                SizedBox(
                  height: kMinInteractiveDimension * 2,
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tap to select a collection',
                            style: ShadTheme.of(context).textTheme.large,
                          ),
                        ),
                      ),
                      Expanded(
                          child: StoreSelector(
                        onFailed: onFailed,
                      ))
                    ],
                  ),
                ),
                Expanded(
                  child: CLGrid(
                    columns: 3,
                    itemCount: items.length + 1,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (index == items.length) {
                        return CreateNewCollection(
                            searchController: searchController);
                      }
                      return SuggestedCollection(
                        item: items[index],
                        searchController: searchController,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class SuggestedCollection extends StatelessWidget {
  const SuggestedCollection(
      {required this.item, required this.searchController, super.key});

  final ViewerEntity item;
  final SearchController searchController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => searchController.closeView(item.label),
        child: GetEntities(
            parentId: item.id,
            errorBuilder: (_, __) => CLEntityView(
                  entity: item,
                ),
            loadingBuilder: () => CLEntityView(
                  entity: item,
                ),
            builder: (children) {
              return CLEntityView(entity: item, children: children);
            }),
      ),
    );
  }
}

class StoreSelector extends ConsumerWidget {
  const StoreSelector({
    required this.onFailed,
    super.key,
  });
  final VoidCallback onFailed;

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
              onPressed: onFailed,
              child: const Text('Failed to get server list'),
            ),
          );
        },
        builder: (stores) {
          if (!stores.contains(targetStore)) {
            return Center(
              child: ShadBadge.destructive(
                onPressed: onFailed,
                child: const Text('Target Store Not found in list !!'),
              ),
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 180),
              child: ShadSelect<CLStore>(
                placeholder: const Text('Select A Server'),
                initialValue: targetStore,
                options: [
                  ...stores.map((e) =>
                      ShadOption(value: e, child: Text(e.store.identity))),
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
            ),
          );
        });
  }
}

final targetStoreProvider = StateProvider<CLStore>((ref) {
  throw Exception('Must be overridden');
});
