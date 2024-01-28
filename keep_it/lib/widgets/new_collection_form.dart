import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import 'add_media_wizard/description_editor.dart';
import 'add_media_wizard/label_viewer.dart';
import 'add_media_wizard/tag_selector.dart';
import 'app_theme.dart';
import 'create_or_select.dart';
import 'search_anchors/cl_searchbar.dart';
import 'wizard_item.dart';

extension EXTListindex<T> on List<T> {
  int? previous(int index) {
    return switch (index) {
      (final int val) when val <= 0 => null,
      (final int val) when val >= length => null,
      _ => index - 1
    };
  }

  int? next(int index) {
    return switch (index) {
      (final int val) when val < 0 => null,
      (final int val) when val >= (length - 1) => null,
      _ => index + 1
    };
  }
}

typedef PageBuilder = Widget Function(
  BuildContext context, {
  required void Function() onNext,
  required void Function() onPrevious,
});

class PickCollectionBase extends ConsumerStatefulWidget {
  const PickCollectionBase({
    required this.suggestedCollections,
    required this.onDone,
    super.key,
    this.allowUpdateDescription = true,
  });

  final void Function({
    required CollectionBase collection,
    List<CollectionBase>? selectedTags,
  }) onDone;
  final List<CollectionBase> suggestedCollections;
  final bool allowUpdateDescription;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      PickCollectionBaseState();
}

class PickCollectionBaseState extends ConsumerState<PickCollectionBase> {
  final PageController pageController = PageController();
  late SearchController labelController;
  late TextEditingController descriptionController;
  late FocusNode labelNode;
  late FocusNode descriptionNode;

  bool onEditLabel = true;
  CollectionBase? collection;
  List<CollectionBase>? selectedTags;

  @override
  void initState() {
    labelController = SearchController();
    descriptionController = TextEditingController();
    labelNode = FocusNode();
    descriptionNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    labelController.dispose();
    descriptionController.dispose();
    labelNode.dispose();
    descriptionNode.dispose();
    super.dispose();
  }

  void changePage(int? i) {
    if (i != null) {
      pageController.animateToPage(
        i,
        duration: const Duration(microseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <PageBuilder>[page0, page1, page2, page3];
    return UpsertCollectionFormTheme(
      child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        itemCount: pages.length,
        itemBuilder: (context, pageNum) {
          return pages[pageNum](
            context,
            onNext: () => changePage(pages.next(pageNum)),
            onPrevious: () => changePage(pages.previous(pageNum)),
          );
        },
      ),
    );
  }

  Widget page3(
    BuildContext context, {
    required void Function() onNext,
    required void Function() onPrevious,
  }) {
    return const Center(child: CLLoadingView(message: 'Saving...'));
  }

  Widget page2(
    BuildContext context, {
    required void Function() onNext,
    required void Function() onPrevious,
  }) {
    if (collection == null) {
      return const Text('Error in previous page');
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LabelViewer(label: 'Collection: ${collection!.label}'),
        Flexible(
          child: TagSelector(
            onDone: (selectedTags) {
              setState(() {
                this.selectedTags = selectedTags;
                widget.onDone(
                  collection: collection!,
                  selectedTags: selectedTags,
                );
              });
              onNext();
            },
          ),
        ),
      ],
    );
  }

  Widget page0(
    BuildContext context, {
    required void Function() onNext,
    required void Function() onPrevious,
  }) {
    return Align(
      child: SizedBox(
        height: kMinInteractiveDimension * 2,
        child: WizardItem(
          child: CreateOrSelect(
            suggestedCollections: widget.suggestedCollections,
            controller: labelController,
            onDone: (CollectionBase collection) async {
              setState(() {
                onEditLabel = false;
                this.collection = collection;
                descriptionController.text = collection.description ?? '';
              });
              labelNode.unfocus();

              onNext();
            },
            anchorBuilder: (
              BuildContext context,
              SearchController controller, {
              required void Function(CollectionBase) onDone,
            }) {
              return CLSearchBarWrap(
                controller: controller,
                focusNode: labelNode,
                onDone: (val) {
                  final c = widget.suggestedCollections
                      .where((element) => element.label == val)
                      .firstOrNull;
                  onDone(c ?? CollectionBase(label: val));
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget page1(
    BuildContext contex, {
    void Function()? onPrevious,
    void Function()? onNext,
  }) {
    if (onEditLabel || collection == null) {
      return const Text('Error in previous page');
    }
    final menuItem = (collection!.id == null)
        ? CLMenuItem(
            title: 'Select Tags',
            icon: MdiIcons.arrowRight,
            onTap: () async {
              descriptionNode.unfocus();
              onNext?.call();
              return null;
            },
          )
        : CLMenuItem(
            title: 'Save',
            icon: MdiIcons.floppyVariant,
            onTap: () async {
              descriptionNode.unfocus();
              widget.onDone(collection: collection!);
              return null;
            },
          );
    return Center(
      child: SizedBox(
        height: kMinInteractiveDimension * 4,
        child: Column(
          children: [
            LabelViewer(
              label: 'Collection: ${collection!.label}',
              icon: MdiIcons.pencil,
              onTap: () {
                setState(() {
                  onEditLabel = true;
                });
                descriptionNode.unfocus();
                onPrevious?.call();
              },
            ),
            Flexible(
              child: WizardItem(
                action: menuItem,
                child: DescriptionEditor(
                  collection!,
                  controller: descriptionController,
                  focusNode: descriptionNode,
                  enabled: widget.allowUpdateDescription,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
