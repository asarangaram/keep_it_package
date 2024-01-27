import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import 'app_theme.dart';
import 'create_or_select.dart';

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

  void changePage(int i) {
    pageController.animateToPage(
      i,
      duration: const Duration(microseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return UpsertCollectionFormTheme(
      child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        itemCount: 2,
        itemBuilder: (context, pageNum) {
          return [
            CreateOrSelect(
              suggestedCollections: widget.suggestedCollections,
              controller: labelController,
              focusNode: labelNode,
              onDone: (CollectionBase collection) {
                setState(() {
                  onEditLabel = false;
                  this.collection = collection;
                });
                changePage(1);
              },
            ),
            if (!onEditLabel && collection != null)
              Column(
                children: [
                  ShowLabel(
                    label: collection!.label,
                    onEditLabel: () {
                      pageController.animateToPage(
                        0,
                        duration: const Duration(microseconds: 200),
                        curve: Curves.easeOut,
                      );
                      setState(() {
                        onEditLabel = true;
                      });
                    },
                  ),
                  Flexible(
                    child: UpdateDescription(
                      collection!,
                      controller: descriptionController,
                      focusNode: descriptionNode,
                      onDone: () {
                        setState(() {
                          collection = collection!.copyWith(
                            description: descriptionController.text,
                          );
                          widget.onDone(collection!);
                        });
                      },
                    ),
                  ),
                ],
              )
            else
              const Text('Item not found'),
          ][pageNum];
        },
      ),
    );
  }
}

class UpdateDescription extends StatefulWidget {
  const UpdateDescription(
    this.item, {
    required this.controller,
    required this.onDone,
    required this.focusNode,
    super.key,
  });
  final CollectionBase item;
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function() onDone;

  @override
  State<UpdateDescription> createState() => _UpdateDescriptionState();
}

class _UpdateDescriptionState extends State<UpdateDescription> {
  @override
  void initState() {
    widget.focusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    widget.focusNode.unfocus();
    super.dispose();
  }

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
              child: CLTextField.multiLine(
                widget.controller,
                focusNode: widget.focusNode,
                hint: 'What is the best thing,'
                    ' you can say about this?',
                maxLines: 5,
              ),
            ),
          ),
          Container(
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
                  widget.item.id == null
                      ? MdiIcons.arrowRight
                      : MdiIcons.floppy,
                  widget.item.id == null ? 'Select Tags' : 'Save',
                  color: Theme.of(context).colorScheme.surface,
                  onTap: widget.onDone,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShowLabel extends StatelessWidget {
  const ShowLabel({
    required this.label,
    required this.onEditLabel,
    super.key,
  });

  final void Function()? onEditLabel;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEditLabel,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: CLScaleType.large.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onEditLabel != null) ...[
            const SizedBox(
              width: 8,
            ),
            Transform.translate(
              offset: const Offset(0, -4),
              child: const CLIcon.verySmall(
                Icons.edit,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
