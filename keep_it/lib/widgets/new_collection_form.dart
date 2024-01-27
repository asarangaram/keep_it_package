import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'app_theme.dart';

class UpdateCollection extends ConsumerStatefulWidget {
  const UpdateCollection({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewCollectionState();
}

class _NewCollectionState extends ConsumerState<UpdateCollection> {
  final PageController pageController = PageController();
  late SearchController labelController;
  late TextEditingController descriptionController;
  late FocusNode labelNode;
  late FocusNode descriptionNode;

  bool onEditLabel = true;
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

  String? label;
  String? description;
  @override
  Widget build(BuildContext context) {
    return UpsertCollectionFormTheme(
      child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        itemCount: 2,
        itemBuilder: (context, pageNum) {
          return [
            getLabel(),
            if (!onEditLabel)
              getDescription()
            else
              const Text('Label not found'),
          ][pageNum];
        },
      ),
    );
  }

  Widget getDescription() {
    return GetDescription(
      label: label!,
      controller: descriptionController,
      focusNode: descriptionNode,
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
    );
  }

  Widget getLabel() {
    return GetLabel(
      controller: labelController,
      focusNode: labelNode,
      onLabel: (text) {
        setState(
          () {
            label = text.isEmpty ? null : text;
            label.toString().printString(prefix: 'label is :');
            if (label != null) {
              pageController.animateToPage(
                1,
                duration: const Duration(microseconds: 200),
                curve: Curves.easeOut,
              );
              setState(() {
                onEditLabel = false;
              });
            }
          },
        );
      },
    );
  }
}

class GetDescription extends StatefulWidget {
  const GetDescription({
    required this.label,
    required this.controller,
    required this.onEditLabel,
    this.focusNode,
    super.key,
  });
  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final void Function() onEditLabel;

  @override
  State<GetDescription> createState() => _GetDescriptionState();
}

class _GetDescriptionState extends State<GetDescription> {
  late String label;

  @override
  void initState() {
    label = widget.label;
    if (!(widget.focusNode?.hasFocus ?? false)) {
      widget.focusNode?.requestFocus();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: kMinInteractiveDimension * 1,
          child: GestureDetector(
            onTap: widget.onEditLabel,
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
                const SizedBox(
                  width: 8,
                ),
                Transform.translate(
                  offset: const Offset(0, -4),
                  child: const CLIcon.small(
                    Icons.edit,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: kMinInteractiveDimension * 3,
          child: Padding(
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
                        MdiIcons.arrowRight,
                        'Select Tags',
                        color: Theme.of(context).colorScheme.surface,
                        onTap: () {},
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GetLabel extends StatefulWidget {
  const GetLabel({
    required this.onLabel,
    this.controller,
    this.focusNode,
    super.key,
  });
  final void Function(String text) onLabel;
  final SearchController? controller;
  final FocusNode? focusNode;

  @override
  State<GetLabel> createState() => _GetLabelState();
}

class _GetLabelState extends State<GetLabel> {
  void _listener() {
    /* if (widget.focusNode?.hasFocus ?? false) {
      if (!(widget.controller?.isOpen ?? false)) {
        widget.controller?.openView();
      }
    } else {
      if (widget.controller?.isOpen ?? false) {
        widget.controller?.closeView(null);
      }
    } */
    print('focus node lisnter');
  }

  @override
  void initState() {
    if (!(widget.focusNode?.hasFocus ?? false)) {
      widget.focusNode?.requestFocus();
    }

    super.initState();
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: kMinInteractiveDimension * 2,
          child: Row(
            children: [
              Flexible(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SearchAnchor(
                    searchController: widget.controller,
                    isFullScreen: false,
                    viewBackgroundColor: Theme.of(context).colorScheme.surface,
                    dividerColor: Colors.blue,
                    headerTextStyle: const TextStyle(color: Colors.blue),
                    headerHintStyle: const TextStyle(color: Colors.blue),
                    builder: (
                      BuildContext context,
                      SearchController controller,
                    ) {
                      return SearchBar(
                        focusNode: widget.focusNode,
                        controller: controller,
                        padding: const MaterialStatePropertyAll<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onTap: () {
                          controller.openView();
                        },
                        onChanged: (_) {
                          controller.openView();
                        },
                        onSubmitted: (val) {
                          widget.focusNode?.unfocus();
                          widget.onLabel(val);
                        },
                        leading: const CLIcon.small(Icons.search),
                        hintText: 'Collection Name',
                      );
                    },
                    viewHintText: 'Enter Collection Name',
                    suggestionsBuilder: (
                      BuildContext context,
                      SearchController controller,
                    ) {
                      final list = suggestedCollections.where(
                        (element) {
                          if (controller.text.isEmpty) return true;
                          return element.toLowerCase().contains(
                                controller.text.toLowerCase(),
                              );
                        },
                      ).map((e) {
                        return ListTile(
                          title: Text(e),
                          onTap: () {
                            setState(() {
                              widget.focusNode?.unfocus();
                              controller.closeView(e);
                            });
                            widget.onLabel(e);
                          },
                        );
                      }).toList();
                      if (list.isEmpty) {
                        list.add(
                          ListTile(
                            title: Text('Create "${controller.text}"'),
                            onTap: () {
                              setState(() {
                                controller.closeView(controller.text);
                              });
                            },
                          ),
                        );
                      }
                      return list
                        ..add(
                          ListTile(
                            title: SizedBox(
                              height: MediaQuery.of(context).viewInsets.bottom,
                            ),
                          ),
                        );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const CLText.large(
          'Select a most appropriate collection or create one to proceed',
        ),
      ],
    );
  }
}

const List<String> suggestedCollections = [
  'Aki 11th Birthday',
  'Ami Birthday',
  'Republic day',
  'Diwali',
];
