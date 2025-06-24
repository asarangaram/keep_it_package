import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import 'pick_collection/wizard_error.dart';
import 'search_collection/search_bar.dart';
import 'search_collection/search_view.dart';
import 'search_collection/text_edit_box.dart';

class PickCollection extends StatefulWidget implements PreferredSizeWidget {
  const PickCollection({
    required this.collection,
    required this.onDone,
    super.key,
    this.isValidSuggestion,
  });
  final StoreEntity? collection;
  final void Function(StoreEntity) onDone;
  final bool Function(StoreEntity collection)? isValidSuggestion;

  @override
  State<PickCollection> createState() => _PickCollectionState();

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension * 3);
}

class _PickCollectionState extends State<PickCollection> {
  late final TextEditingController viewController;
  late final TextEditingController searchController;
  late StoreEntity? collection;

  @override
  void initState() {
    collection = widget.collection;
    viewController = TextEditingController();
    viewController.text = widget.collection?.data.label ?? '';
    searchController = TextEditingController();
    viewController.text = widget.collection?.data.label ?? '';
    super.initState();
  }

  @override
  void dispose() {
    viewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'Search bar',
      child: TextEditBox(
        controller: viewController,
        collection: collection,
        onTap: () async {
          final result = await showModalBottomSheet<StoreEntity>(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(),
              constraints: const BoxConstraints(),
              useSafeArea: true,
              isDismissible: false,
              builder: (BuildContext context) {
                return CollectionSearchView(
                  collection: collection,
                );
              });

          if (result != null) {
            setState(() {
              collection = result;
            });
          }
          viewController.text = collection?.label ?? '';
        },
        menuItem: CLMenuItem(
            title: 'Keep',
            icon: LucideIcons.folderInput,
            onTap: collection == null
                ? null
                : () async {
                    widget.onDone(collection!);
                    return true;
                  }),
      ),
    );
  }
}

class CollectionSearchView extends StatefulWidget {
  const CollectionSearchView({required this.collection, super.key});

  final ViewerEntity? collection;

  @override
  State<StatefulWidget> createState() => _CollectionSearchViewState();
}

class _CollectionSearchViewState extends State<CollectionSearchView> {
  late final TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController(text: widget.collection?.label ?? '');
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onClose() => Navigator.of(context).pop;
  void onSelect(ViewerEntity entity) => Navigator.of(context).pop(entity);

  @override
  Widget build(BuildContext context) {
    return GetActiveStore(
        loadingBuilder: () => CLLoader.widget(debugMessage: null),
        errorBuilder: (e, st) {
          return WizardError(
            error: e.toString(),
            onClose: onClose,
          );
        },
        builder: (activeStore) {
          return Column(
            children: [
              EntitySearchBar(
                controller: controller,
                onClose: onClose,
              ),
              Expanded(
                  child: SearchView(
                controller: controller,
                targetStore:
                    (widget.collection as StoreEntity?)?.store ?? activeStore,
                onClose: onClose,
                onSelect: onSelect,
              )),
            ],
          );
        });
  }
}
