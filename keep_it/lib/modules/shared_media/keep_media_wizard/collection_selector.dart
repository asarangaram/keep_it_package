import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:keep_it/widgets/collection/collections_dialog.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import 'collection_create_select.dart';
import 'wizard_item.dart';

class CollectionSelector extends StatefulWidget {
  const CollectionSelector({
    required this.entities,
    required this.availableSuggestions,
    required this.onDone,
    required this.onCreateNew,
    super.key,
  });
  final List<Collection> entities;
  final List<Collection> availableSuggestions;
  final void Function(List<Collection> selectedTags) onDone;
  final Collection Function(Collection entity) onCreateNew;

  @override
  State<CollectionSelector> createState() => _KeepItItemSelectorState();
}

class _KeepItItemSelectorState extends State<CollectionSelector> {
  late ScrollController scrollController;
  final GlobalKey wrapKey = GlobalKey();

  List<Collection> selectedEntities = [];
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

  Future<void> onDone(Collection c) async {
    final Collection entityUpdated;
    if (c.id == null) {
      final res = await CollectionsDialog.upsert(context, entity: c);
      if (res == null) {
        return;
      }
      entityUpdated = widget.onCreateNew(res);
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
                  CollectionCreateOrSelect(
                    controller: controller,
                    onDone: onDone,
                    anchorBuilder: (
                      BuildContext context,
                      SearchController controller, {
                      required void Function(Collection) onDone,
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
