import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:keep_it/widgets/from_store/from_store.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import '../create_or_select.dart';
import '../wizard_item.dart';

class TagSelector extends StatefulWidget {
  const TagSelector({
    required this.onDone,
    super.key,
  });

  final void Function(List<Tag> selectedTags) onDone;

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  late ScrollController scrollController;
  final GlobalKey wrapKey = GlobalKey();

  List<Tag> selectedTags = [];
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

  Future<void> onDone(CollectionBase c) async {
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
    Future.delayed(const Duration(milliseconds: 200), scrollToEnd);
  }

  @override
  Widget build(BuildContext context) {
    return LoadTags(
      buildOnData: (tags) {
        return WizardItem(
          action: selectedTags.isEmpty
              ? null
              : CLMenuItem(title: 'Save', icon: MdiIcons.floppy),
          child: SizedBox.expand(
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
                      ...selectedTags.map(
                        (e) => Theme(
                          data: Theme.of(context).copyWith(
                            chipTheme: const ChipThemeData(
                              side: BorderSide.none,
                            ),
                            canvasColor: Colors.transparent,
                          ),
                          child: Chip(
                            label: Text(e.label),
                            onDeleted: () {
                              setState(() {
                                selectedTags.remove(e);
                              });
                            },
                          ),
                        ),
                      ),
                      CreateOrSelect(
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
                        anchorBuilder: (
                          BuildContext context,
                          SearchController controller, {
                          required void Function(CollectionBase) onDone,
                        }) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Colors.transparent,
                            ),
                            child: ActionChip(
                              avatar: Icon(MdiIcons.plus),
                              label: Text(
                                selectedTags.isEmpty
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
        );
      },
    );
  }
}
