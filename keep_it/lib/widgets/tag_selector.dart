import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:keep_it/widgets/from_store/from_store.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import 'create_or_select.dart';
import 'search_anchors/cl_search_chip.dart';
import 'wizard_item.dart';

class TagSelector extends StatefulWidget {
  const TagSelector({
    super.key,
  });

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  List<Tag> selectedTags = [];
  late SearchController controller;
  @override
  void initState() {
    controller = SearchController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onDone(CollectionBase c) {
    setState(() {
      if (c.id != null) {
        //need to popup to create
        selectedTags.add(Tag.fromBase(c));
      } else {
        selectedTags.add(
          Tag.fromBase(c),
        );
      }

      controller.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadTags(
      buildOnData: (tags) {
        return WizardItem(
          action: selectedTags.isEmpty
              ? null
              : CLMenuItem(title: 'Save', icon: MdiIcons.floppy),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisAlignment: selectedTags.isNotEmpty
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          ...selectedTags.map(
                            (e) => Chip(
                              label: Text(e.label),
                              onDeleted: () {
                                setState(() {
                                  selectedTags.remove(e);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: CreateOrSelect(
                        controller: controller,
                        onDone: onDone,
                        suggestedCollections: [
                          ...tags.entries,
                          ...suggestedTags.where((element) {
                            return !tags.entries
                                .map((e) => e.label)
                                .contains(element.label);
                          }),
                        ]
                            .where(
                              (element) => !selectedTags
                                  .map((e) => e.label)
                                  .contains(element.label),
                            )
                            .toList(),
                        anchorBuilder: (context, controller) {
                          return SearchAnchorChip(
                            label: selectedTags.isEmpty
                                ? 'Add Tag'
                                : 'Add Another Tag',
                            controller: controller,
                            onDone: (val) {
                              final c = tags.entries
                                  .where((element) => element.label == val)
                                  .firstOrNull;
                              setState(() {
                                onDone(c ?? CollectionBase(label: val));
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
