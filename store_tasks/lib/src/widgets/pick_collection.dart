import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_factory/form_factory.dart';
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
    /* if (widget.collection == null &&
        searchController.isAttached &&
        !searchController.isOpen) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => searchController.openView());
    } */
    return SizedBox.fromSize(
      size: widget.preferredSize,
      child: WizardDialog2(
        child: CollectionAnchor(
          searchController: searchController,
          textEditingController: textEditingController,
          suggestionsBuilder: suggestionsBuilder,
        ),
      ),
    );
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
        textEditingController: textEditingController,
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
      required this.textEditingController,
      required this.suggestionsBuilder,
      super.key});
  final FutureOr<Iterable<Widget>> Function(BuildContext, SearchController)
      suggestionsBuilder;
  final SearchController searchController;
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchAnchor(
      searchController: searchController,
      isFullScreen: true,
      suggestionsBuilder: suggestionsBuilder,
      builder: (context, controller) {
        return InputDecorator(
          decoration: InputDecoration(
              //isDense: true,
              contentPadding: const EdgeInsets.fromLTRB(20, 8, 4, 8),
              labelText: 'Select a collection',
              labelStyle: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                gapPadding: 8,
              ),
              suffixIcon: FractionallySizedBox(
                widthFactor: 0.2,
                heightFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        CLTheme.of(context).colors.wizardButtonBackgroundColor,
                    border: Border.all(),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Align(
                    child: CLButtonIconLabelled.standard(
                      LucideIcons.folderInput,
                      'Keep',
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              )),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Expanded(
                  flex: 13,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: TextField(
                      decoration: InputDecoration(
                          hintStyle: ShadTheme.of(context).textTheme.muted,
                          hintText: 'Tap here to select a collection'),
                      controller: textEditingController,
                      onTap: searchController.openView,
                      onChanged: (_) => searchController.openView(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Server100@cloudonlanapps',
                        style: ShadTheme.of(context)
                            .textTheme
                            .muted
                            .copyWith(color: Colors.red),
                      )),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
