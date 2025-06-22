import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import 'wizard_error.dart';

class CollectionAnchor extends ConsumerWidget {
  const CollectionAnchor(
      {required this.collection, required this.searchController, super.key});
  final StoreEntity? collection;

  final SearchController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetEntities(
        isCollection: true,
        //isHidden: null,
        isDeleted: null,
        loadingBuilder: () => CLLoader.widget(debugMessage: null),
        errorBuilder: (e, st) => WizardError.show(context, e, st),
        builder: (entities) {
          return SearchAnchor(
            searchController: searchController,
            isFullScreen: true,
            viewBuilder: (suggestions) {
              final items = suggestions.toList();
              return Padding(
                padding: const EdgeInsets.all(8),
                child: CLGrid(
                  columns: 3,
                  itemCount: items.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return items[index];
                  },
                ),
              );
            },
            suggestionsBuilder: (context, controller) {
              final suggestions = <Widget>[];
              if (controller.text.isEmpty) {
                suggestions.addAll(entities.entities.map((e) => Center(
                      child: GetEntities(
                          parentId: e.id,
                          errorBuilder: (_, __) => const BrokenImage(),
                          loadingBuilder: () => const GreyShimmer(),
                          builder: (children) {
                            return CLEntityView(entity: e, children: children);
                          }),
                    )));
              } else {
                suggestions.addAll(entities.entities
                    .where((e) => e.label!.startsWith(searchController.text))
                    .map((e) => GetEntities(
                        parentId: e.id,
                        errorBuilder: (_, __) => const BrokenImage(),
                        loadingBuilder: () => const GreyShimmer(),
                        builder: (children) {
                          return CLEntityView(entity: e, children: children);
                        })));
              }
              suggestions.add(Container(
                child: const Icon(Icons.add),
              ));
              return suggestions;
            },
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Expanded(
                    flex: 13,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: TextFormField(
                        initialValue: collection?.label,
                        decoration: collection == null
                            ? InputDecoration(
                                hintStyle:
                                    ShadTheme.of(context).textTheme.muted,
                                hintText: 'Tap here to select a collection')
                            : null,
                        readOnly: true,
                        showCursor: false,
                        enableInteractiveSelection: false,
                        onTap: searchController.openView,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: collection == null
                            ? null
                            : ServerLabel(
                                store: collection!.store,
                              )),
                  )
                ],
              );
            },
          );
        });
  }
}

class ServerLabel extends ConsumerWidget {
  const ServerLabel({required this.store, super.key});
  final CLStore store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = store.store.identity == 'default'
        ? 'On this device'
        : store.store.identity;
    final Color color;
    switch (store.store.storeURL.scheme) {
      case 'http':
      case 'https':
        color = Colors.green; // When offline, change to red
      default:
        color = Colors.grey.shade400;
    }
    return Text(
      label,
      style: ShadTheme.of(context).textTheme.muted.copyWith(color: color),
    );
  }
}
