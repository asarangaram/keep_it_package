import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import 'app_theme.dart';
import 'create_or_select.dart';
import 'search_anchors/cl_search_chip.dart';
import 'search_anchors/cl_searchbar.dart';

extension EXTListindex<T> on List<T> {
  int? previous(int index) {
    return switch (index) {
      (final int val) when val <= 0 => null,
      (final int val) when val >= length => null,
      _ => index + 1
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

  final void Function(CollectionBase collection) onDone;
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
    final pages = <PageBuilder>[page0, page1];
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

  Widget page2(
    BuildContext context, {
    required void Function() onNext,
    required void Function() onPrevious,
  }) {
    return const Center(child: Text('Select Tags'));
  }

  Widget page0(
    BuildContext context, {
    required void Function() onNext,
    required void Function() onPrevious,
  }) {
    void onDone(CollectionBase collection) {
      setState(() {
        onEditLabel = false;
        this.collection = collection;
        descriptionController.text = collection.description ?? '';
      });

      onNext();
    }

    return CreateOrSelect(
      suggestedCollections: widget.suggestedCollections,
      controller: labelController,
      focusNode: labelNode,
      onDone: onDone,
      anchorBuilder: (
        BuildContext context,
        SearchController searchController,
      ) {
        return CLSearchBarWrap(
          controller: searchController,
          focusNode: descriptionNode,
          onDone: (val) {
            final c = widget.suggestedCollections
                .where((element) => element.label == val)
                .firstOrNull;
            onDone(c ?? CollectionBase(label: val));
          },
        );
      },
    );
  }

  Widget page1(
    BuildContext contex, {
    void Function()? onPrevious,
    void Function()? onNext,
  }) {
    if (onEditLabel || collection == null) {
      const Text('Error in previous page');
    }
    final menuItem = (collection!.id == null)
        ? CLMenuItem(
            title: 'Select Tags',
            icon: MdiIcons.arrowRight,
            onTap: () async {
              onNext?.call();
              return null;
            },
          )
        : CLMenuItem(
            title: 'Save',
            icon: MdiIcons.floppyVariant,
            onTap: () async {
              widget.onDone(collection!);
              return null;
            },
          );
    return Column(
      children: [
        ShowLabel(
          menuItem: CLMenuItem(
            title: collection?.label ?? '',
            icon: MdiIcons.pencil,
            onTap: () async {
              setState(() {
                onEditLabel = true;
              });
              onPrevious?.call();
              return null;
            },
          ),
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
    );
  }
}

class WizardItem extends StatelessWidget {
  const WizardItem({
    required this.child,
    required this.action,
    super.key,
  });
  final Widget child;
  final CLMenuItem action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Flexible(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(),
                  left: BorderSide(),
                  bottom: BorderSide(),
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: child,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: CLButtonIconLabelled.large(
                  action.icon,
                  action.title,
                  onTap: action.onTap,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DescriptionEditor extends ConsumerStatefulWidget {
  const DescriptionEditor(
    this.item, {
    required this.controller,
    required this.focusNode,
    required this.enabled,
    super.key,
  });
  final CollectionBase item;
  final TextEditingController controller;
  final FocusNode focusNode;

  final bool enabled;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DescriptionEditorState();
}

class _DescriptionEditorState extends ConsumerState<DescriptionEditor> {
  late bool enabled;
  @override
  void initState() {
    enabled = widget.controller.text.isEmpty && widget.enabled;
    if (enabled) {
      widget.focusNode.requestFocus();
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    super.initState();
  }

  @override
  void dispose() {
    widget.focusNode.unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enabled && enabled && !widget.focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.focusNode.requestFocus();
      });
    }
    return GestureDetector(
      onTap: widget.enabled && !enabled
          ? () async {
              setState(() {
                enabled = true;
              });
            }
          : null,
      child: CLTextField.multiLine(
        widget.controller,
        focusNode: widget.focusNode,
        hint: 'What is the best thing,'
            ' you can say about this?',
        maxLines: 5,
        enabled: enabled,
      ),
    );
  }
}

class ShowLabel extends StatelessWidget {
  const ShowLabel({
    required this.menuItem,
    super.key,
  });

  final CLMenuItem menuItem;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: menuItem.onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            menuItem.title,
            style: TextStyle(
              fontSize: CLScaleType.large.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (menuItem.onTap != null) ...[
            const SizedBox(
              width: 8,
            ),
            Transform.translate(
              offset: const Offset(0, -4),
              child: CLIcon.verySmall(
                menuItem.icon,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
