import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Selector extends StatefulWidget {
  const Selector({
    required this.entities,
    required this.availableSuggestions,
    required this.onDone,
    required this.onSelect,
    required this.onCreateByLabel,
    required this.labelBuilder,
    this.descriptionBuilder,
    super.key,
  });
  final List<Object> entities;
  final List<Object> availableSuggestions;
  final void Function(List<Object> selectedTags) onDone;

  final Future<Object?> Function(Object item) onSelect;
  final Future<Object?> Function(String label) onCreateByLabel;
  final String Function(Object e) labelBuilder;
  final String? Function(Object e)? descriptionBuilder;

  @override
  State<Selector> createState() => SelectorState();
}

class SelectorState extends State<Selector> {
  late ScrollController scrollController;
  final GlobalKey wrapKey = GlobalKey();

  List<Object> selectedEntities = [];
  late SearchController controller;
  @override
  void initState() {
    controller = SearchController();
    scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void scrollToEnd() {
    if (wrapKey.currentContext != null) {
      //final renderBox = wrapKey.currentContext?.findRenderObject();
      final maxScroll = scrollController.position.maxScrollExtent;
      scrollController.jumpTo(maxScroll);
    }
  }

  Future<void> onSelect(Object item) async {
    final entityUpdated = await widget.onSelect(item);
    if (entityUpdated == null) return;
    setState(() {
      selectedEntities.add(entityUpdated);
      controller.text = '';
    });
    Future.delayed(const Duration(milliseconds: 200), scrollToEnd);
  }

  Future<void> onCreateByLabel(String label) async {
    final entityUpdated = await widget.onCreateByLabel(label);
    if (entityUpdated == null) return;
    setState(() {
      selectedEntities.add(entityUpdated);
      controller.text = '';
    });
    Future.delayed(const Duration(milliseconds: 200), scrollToEnd);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CLFormSelect(
        scrollController: scrollController,
        wrapKey: wrapKey,
        selectedEntities: selectedEntities,
        searchController: controller,
        labelBuilder: widget.labelBuilder,
        descriptionBuilder: widget.descriptionBuilder,
        onDelete: (Object e) {
          setState(() {
            selectedEntities.remove(e);
          });
        },
        suggestions: [
          ...widget.entities,
          ...widget.availableSuggestions
              .excludeByLabel(widget.entities, widget.labelBuilder),
        ].excludeByLabel(selectedEntities, widget.labelBuilder).toList(),
        onSelect: onSelect,
        onCreateByLabel: onCreateByLabel,
      ),
    );
  }
}

class CLFormSelect extends StatelessWidget {
  const CLFormSelect({
    required this.scrollController,
    required this.wrapKey,
    required this.selectedEntities,
    required this.searchController,
    required this.labelBuilder,
    required this.onDelete,
    required this.onSelect,
    required this.onCreateByLabel,
    this.descriptionBuilder,
    this.suggestions,
    super.key,
  });
  final ScrollController scrollController;
  final GlobalKey wrapKey;
  final List<Object> selectedEntities;
  final SearchController searchController;
  final String Function(Object e) labelBuilder;
  final String? Function(Object e)? descriptionBuilder;
  final void Function(Object e) onDelete;
  final List<Object>? suggestions;
  final Future<Object?> Function(Object item) onSelect;
  final Future<Object?> Function(String label) onCreateByLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all()),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CLText.large(
            'Tags',
            textAlign: TextAlign.start,
          ),
          Container(
            // decoration: BoxDecoration(border: Border.all()),
            child: SizedBox(
              width: double.infinity,
              height: kMinInteractiveDimension * 6,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      key: wrapKey,
                      spacing: 1,
                      runSpacing: 1,
                      children: [
                        ...selectedEntities.map(
                          (e) => Theme(
                            data: Theme.of(context).copyWith(
                              chipTheme: const ChipThemeData(
                                side: BorderSide.none,
                              ),
                              canvasColor: Colors.transparent,
                            ),
                            child: Chip(
                              label: Text(labelBuilder(e)),
                              onDeleted: () => onDelete(e),
                            ),
                          ),
                        ),
                        SearchAnchor(
                          searchController: searchController,
                          isFullScreen: false,
                          viewBackgroundColor:
                              Theme.of(context).colorScheme.surface,
                          suggestionsBuilder: (context, controller) {
                            return suggestionsBuilder(
                              context,
                              suggestions: suggestions,
                              controller: controller,
                              labelBuilder: labelBuilder,
                              onSelect: onSelect,
                              onCreateByLabel: onCreateByLabel,
                            );
                          },
                          builder: (context, controller) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                canvasColor: Colors.transparent,
                              ),
                              child: ActionChip(
                                avatar: Icon(MdiIcons.plus),
                                label: Text(
                                  selectedEntities.isEmpty
                                      ? 'Add Tag'
                                      : 'Add Another Tag',
                                ),
                                onPressed: controller.openView,
                                shape: const ContinuousRectangleBorder(
                                  side: BorderSide(),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  FutureOr<Iterable<Widget>> suggestionsBuilder(
    BuildContext context, {
    required SearchController controller,
    required String Function(Object e) labelBuilder,
    required Future<Object?> Function(Object item) onSelect,
    required Future<Object?> Function(String label) onCreateByLabel,
    String Function(Object e)? descriptionBuilder,
    List<Object>? suggestions,
  }) {
    final list = suggestions?.map<Widget>((e) {
          final description = descriptionBuilder?.call(e);
          return ListTile(
            title: Text(labelBuilder(e)),
            subtitle: description == null ? null : Text(description),
            onTap: () {
              controller.closeView(controller.text);
              onSelect(e);
            },
          );
        }).toList() ??
        [];
    if (controller.text.isNotEmpty) {
      final c = suggestions?.getByLabel(controller.text, labelBuilder);

      if (c == null) {
        list.add(
          ListTile(
            title: Text('Create "${controller.text}"'),
            onTap: () {
              if (controller.text.isNotEmpty) {
                controller.closeView(controller.text);

                final c = suggestions?.getByLabel(
                  controller.text,
                  labelBuilder,
                );
                if (c == null) {
                  onCreateByLabel(controller.text);
                } else {
                  onSelect(c);
                }
              }
            },
          ),
        );
      }
    }
    return list
      ..add(
        ListTile(
          title: SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          ),
        ),
      );
  }
}
