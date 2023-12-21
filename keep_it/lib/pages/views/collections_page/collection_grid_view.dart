import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../app_theme.dart';
import 'add_collection.dart';
import 'main_header.dart';
import 'paginated_grid.dart';

class CollectionGridView extends ConsumerStatefulWidget {
  const CollectionGridView({super.key, required this.collections});

  final Collections collections;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      CollectionGridViewState();
}

class CollectionGridViewState extends ConsumerState<CollectionGridView> {
  final GlobalKey quickMenuScopeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return CLFullscreenBox(
      useSafeArea: true,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CLQuickMenuScope(
          key: quickMenuScopeKey,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MainHeader(quickMenuScopeKey: quickMenuScopeKey),
                const Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CLText.large(
                          "Your Collections",
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: AddNewCollection(),
                    )
                  ],
                ),
                Flexible(
                  child: (widget.collections.isEmpty)
                      ? const Center(
                          child: CLText.small(
                            "No collections found",
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, BoxConstraints constraints) {
                            return PaginatedGrid(
                              collections: widget.collections.entries,
                              constraints: constraints,
                              quickMenuScopeKey: quickMenuScopeKey,
                            );
                          },
                        ),
                ),
                /* const SizedBox(
                  height: 8,
                ),
                AddNewCollection(quickMenuScopeKey: quickMenuScopeKey), */
              ]),
        ),
      ),
    );
  }
}
