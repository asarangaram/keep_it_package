import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';
import 'package:store_tasks/src/widgets/search_collection/collection_search_view.dart';

import 'pick_collection/pick_wizard.dart';
import 'pick_collection/server_label.dart';
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
      child: SizedBox(
        height: kMinInteractiveDimension * 3,
        child: PickWizard(
          menuItem: CLMenuItem(
              title: 'Keep',
              icon: LucideIcons.folderInput,
              onTap: collection == null
                  ? null
                  : () async {
                      widget.onDone(collection!);
                      return true;
                    }),
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
            serverWidget: collection == null
                ? null
                : ServerLabel(
                    store: (collection!).store,
                  ),
          ),
        ),
      ),
    );
  }
}
