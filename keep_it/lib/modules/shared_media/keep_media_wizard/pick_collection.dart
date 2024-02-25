import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'collection_editor.dart';

import 'edit_tags_in_collection.dart';
import 'label_viewer.dart';
import 'pure/wizard_item.dart';
import 'select_collection.dart';

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

class PickCollection extends ConsumerStatefulWidget {
  const PickCollection({
    required this.suggestedCollections,
    required this.onDone,
    super.key,
    this.allowUpdateDescription = true,
    this.preSelectedCollection,
  });

  final void Function({
    required Collection collection,
    List<Tag>? selectedTags,
  }) onDone;
  final List<Collection> suggestedCollections;
  final Collection? preSelectedCollection;
  final bool allowUpdateDescription;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => PickCollectionState();
}

class PickCollectionState extends ConsumerState<PickCollection> {
  late final PageController pageController;
  late final SearchController labelController;
  late final TextEditingController descriptionController;
  late final FocusNode labelNode;
  late final FocusNode descriptionNode;

  bool onEditLabel = true;
  Collection? collection;
  List<Tag>? selectedTags;

  @override
  void initState() {
    collection = widget.preSelectedCollection;
    labelController = SearchController();
    labelNode = FocusNode();
    descriptionNode = FocusNode();
    if (collection == null) {
      onEditLabel = true;
      pageController = PageController();
      descriptionController = TextEditingController();
      labelNode.requestFocus();
    } else {
      onEditLabel = false;
      pageController = PageController(initialPage: 1);
      descriptionController =
          TextEditingController(text: collection!.description);
      descriptionNode.requestFocus();
    }

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

  void changePage(int? i, int maxCount) {
    if (i != null && i >= 0 && i < maxCount) {
      pageController.animateToPage(
        i,
        duration: const Duration(microseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <PageBuilder>[
      page0,
      page1,
      page2,
    ];
    return UpsertCollectionFormTheme(
      child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        itemCount: pages.length,
        itemBuilder: (context, pageNum) {
          return pages[pageNum](
            context,
            onNext: () => changePage(pages.next(pageNum), pages.length),
            onPrevious: () => changePage(pages.previous(pageNum), pages.length),
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
      children: [
        LabelViewer(label: 'Collection: ${collection!.label}'),
        Flexible(
          child: EditTagsInCollection(
            collection: collection!,
            onDone: (tags) {
              widget.onDone(collection: collection!, selectedTags: tags);
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
    return SelectCollection(
      collection: collection,
      onDone: (collection) {
        setState(() {
          onEditLabel = false;
          this.collection = collection;
        });
      },
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
              if (descriptionController.text.isNotEmpty) {
                if (collection?.description != descriptionController.text) {
                  setState(() {
                    collection = collection?.copyWith(
                      description: descriptionController.text,
                    );
                  });
                }
              }
              onNext?.call();
              return null;
            },
          )
        : CLMenuItem(
            title: 'Save',
            icon: Icons.save_rounded,
            onTap: () async {
              descriptionNode.unfocus();
              if (descriptionController.text.isNotEmpty) {
                if (collection?.description != descriptionController.text) {
                  setState(() {
                    collection = collection?.copyWith(
                      description: descriptionController.text,
                    );
                  });
                }
              }
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
                child: CollectionEditor(
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

class UpsertCollectionFormTheme extends ConsumerWidget {
  const UpsertCollectionFormTheme({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = MaterialStateProperty.all(
      const Color.fromARGB(0, 0, 0, 0),
    );

    final themeData = Theme.of(context).copyWith(
      searchBarTheme: SearchBarThemeData(
        textStyle: MaterialStateProperty.all(
          const TextStyle(color: Colors.blue),
        ),
        textCapitalization: TextCapitalization.words,
        backgroundColor: color,
        shadowColor: color,
        surfaceTintColor: color,
        overlayColor: color,
        shape: MaterialStateProperty.all(
          const ContinuousRectangleBorder(),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(4),
      ),
    );
    return Theme(
      data: themeData,
      child: child,
    );
  }
}
