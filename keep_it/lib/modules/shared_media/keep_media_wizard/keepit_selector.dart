import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import '../dialogs/dialogs.dart';
import 'create_or_select.dart';
import 'wizard_item.dart';

class TagsSelector extends StatefulWidget {
  const TagsSelector({
    required this.entities,
    required this.availableSuggestions,
    required this.onDone,
    required this.onCreateNew,
    super.key,
  });
  final List<Tag> entities;
  final List<Tag> availableSuggestions;
  final void Function(List<Tag> selectedTags) onDone;
  final Future<Tag> Function(Tag entity) onCreateNew;

  @override
  State<TagsSelector> createState() => _TagsSelectorState();
}

class _TagsSelectorState extends State<TagsSelector> {
  late ScrollController scrollController;
  final GlobalKey wrapKey = GlobalKey();

  List<Tag> selectedEntities = [];
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

  Future<void> onDone(Tag c) async {
    final Tag entityUpdated;
    if (c.id == null) {
      final res = await TagsDialog.upsert(context, entity: c);
      if (res == null) {
        return;
      }
      entityUpdated = await widget.onCreateNew(res);
    } else {
      entityUpdated = c;
    }
    setState(() {
      selectedEntities.add(entityUpdated);
      controller.text = '';
    });
    Future.delayed(const Duration(milliseconds: 200), scrollToEnd);
  }

  @override
  Widget build(BuildContext context) {
    return WizardItem(
      action: selectedEntities.isEmpty
          ? null
          : CLMenuItem(
              title: 'Save',
              icon: MdiIcons.floppy,
              onTap: () async {
                if (selectedEntities.isNotEmpty) {
                  widget.onDone(selectedEntities);
                }
                return selectedEntities.isNotEmpty;
              },
            ),
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
                  ...selectedEntities.map(
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
                            selectedEntities.remove(e);
                          });
                        },
                      ),
                    ),
                  ),
                  CreateOrSelectTags(
                    controller: controller,
                    onDone: onDone,
                    suggestedCollections: [
                      ...widget.entities,
                      ...widget.availableSuggestions.where((element) {
                        return !widget.entities
                            .map((e) => e.label)
                            .contains(element.label);
                      }),
                    ]
                        .where(
                          (element) => !selectedEntities
                              .map((e) => e.label)
                              .contains(element.label),
                        )
                        .toList(),
                    anchorBuilder: (
                      BuildContext context,
                      SearchController controller, {
                      required void Function(Tag) onDone,
                    }) {
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
                            borderRadius: BorderRadius.all(Radius.circular(16)),
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
  }
}
