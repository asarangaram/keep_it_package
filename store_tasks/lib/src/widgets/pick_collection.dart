import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import 'pick_collection/collection_anchor.dart';
import 'pick_collection/pick_wizard.dart';

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
  late final SearchController searchController;
  late StoreEntity? collection;

  @override
  void initState() {
    collection = widget.collection;
    searchController = SearchController();
    searchController.text = widget.collection?.data.label ?? '';
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: widget.preferredSize,
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
        child: CollectionAnchor(
          collection: widget.collection,
          searchController: searchController,
        ),
      ),
    );
  }
}
