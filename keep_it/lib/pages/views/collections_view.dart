import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'app_theme.dart';
import 'collections_page/add_collection.dart';
import 'collections_page/main_header.dart';
import 'collections_page/paginated_grid.dart';

class CollectionsGridView extends ConsumerStatefulWidget {
  const CollectionsGridView({super.key, required this.collections});

  final Collections collections;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CollectionsViewState();
}

class _CollectionsViewState extends ConsumerState<CollectionsGridView> {
  final GlobalKey quickMenuScopeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return CLFullscreenBox(
      useSafeArea: true,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CLQuickMenuScope(
          key: quickMenuScopeKey,
          child: AppTheme(
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
      ),
    );
  }
}
