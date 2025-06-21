import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:store/store.dart';
import 'package:store_tasks/src/widgets/load_shimmer.dart';
import 'package:store_tasks/src/widgets/wizard_error.dart';

import 'wizard_dialog.dart';

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
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension * 2);
}

class _PickCollectionState extends State<PickCollection> {
  late final SearchController searchController;

  @override
  void initState() {
    searchController = SearchController();
    searchController.text = widget.collection?.data.label ?? '';

    // if collection is empty!

    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      throw Exception('this is an error');
    } catch (e) {
      return SizedBox.fromSize(
        size: widget.preferredSize,
        child: GetEntities(
            loadingBuilder: loadingBuilder,
            errorBuilder: errorBuilder,
            builder: (entities) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                //only when the collection is Null
                if (searchController.isAttached && !searchController.isOpen) {
                  searchController.openView();
                }
              });
              return WizardDialog2(
                option1: const CLMenuItem(
                    title: 'Save', icon: LucideIcons.arrowRight),
                child: CollectionAnchor(
                  searchController: searchController,
                  suggestionsBuilder: suggestionsBuilder,
                ),
              );
              /* return ; */
            }),
      );
    }
  }

  Widget errorBuilder([Object? e, StackTrace? st]) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  width: 2, color: ShadTheme.of(context).colorScheme.muted))),
      child: WizardError(
        error: e.toString(),
      ),
    );
  }

  Widget loadingBuilder() {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  width: 2, color: ShadTheme.of(context).colorScheme.muted))),
      child: LoadShimmer(
          child: CollectionAnchor(
        searchController: searchController,
        suggestionsBuilder: suggestionsBuilder,
      )),
    );
  }

  FutureOr<Iterable<Widget>> suggestionsBuilder(
    BuildContext context,
    SearchController controller,
  ) async {
    return [];
  }
}

class CollectionAnchor extends ConsumerWidget {
  const CollectionAnchor(
      {required this.searchController,
      required this.suggestionsBuilder,
      super.key});
  final FutureOr<Iterable<Widget>> Function(BuildContext, SearchController)
      suggestionsBuilder;
  final SearchController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchAnchor(
      searchController: searchController,
      isFullScreen: true,
      suggestionsBuilder: suggestionsBuilder,
      builder: (context, controller) {
        return GestureDetector(
            onTap: controller.openView,
            child: SizedBox.expand(
              child: Center(
                  child: TextField(
                controller: controller,
                onTap: () {
                  controller.openView();
                },
                onChanged: (_) {
                  controller.openView();
                },
              )),
            ));
      },
    );
  }
}
