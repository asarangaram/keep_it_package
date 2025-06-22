import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:store/store.dart';
import 'package:store_tasks/src/widgets/collection_anchor.dart';
import 'package:store_tasks/src/widgets/pick_wizard.dart';
import 'package:store_tasks/src/widgets/wizard_error.dart';

import 'with_target_store.dart';

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
  late final TextEditingController textEditingController;

  @override
  void initState() {
    searchController = SearchController();
    textEditingController = TextEditingController();
    searchController.text = widget.collection?.data.label ?? '';
    textEditingController.text = widget.collection?.data.label ?? '';
    // if collection is empty!

    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: widget.preferredSize,
      child: WithTargetStore(
          collection: widget.collection,
          loadingBuilder: () =>
              PickWizard(child: CLLoader.widget(debugMessage: null)),
          errorBuilder: ([e, st]) => WizardError.show(context, e, st),
          builder: () {
            /* if (widget.collection == null &&
                  searchController.isAttached &&
                  !searchController.isOpen) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => searchController.openView());
              } */
            return PickWizard(
              menuItem: const CLMenuItem(
                title: 'Keep',
                icon: LucideIcons.folderInput,
              ),
              child: CollectionAnchor(
                searchController: searchController,
                textEditingController: textEditingController,
                suggestionsBuilder: suggestionsBuilder,
              ),
            );
          }),
    );
  }

  FutureOr<Iterable<Widget>> suggestionsBuilder(
    BuildContext context,
    SearchController controller,
  ) async {
    return [];
  }
}
