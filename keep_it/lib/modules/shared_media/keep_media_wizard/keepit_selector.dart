import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../widgets/editors/tag_editor.dart';
import '../dialogs/dialogs.dart';
import 'create_or_select.dart';
import 'pure/wizard_item.dart';

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
  late CLFormSelectState state;
  final GlobalKey wrapKey = GlobalKey();
  late CLFormSelectDescriptors descriptor;

  @override
  void initState() {
    descriptor = CLFormSelectDescriptors(
      title: 'Tags',
      label: 'Select Tags',
      labelBuilder: (e) => (e as Tag).label,
      descriptionBuilder: (e) => (e as Tag).description,
      suggestionsAvailable: widget.availableSuggestions,
      initialValues: widget.entities,
      onSelectSuggestion: (item) => create(context, item as Tag),
      onCreateByLabel: (label) => create(context, Tag(label: label)),
    );
    state = CLFormSelectState(
      scrollController: ScrollController(),
      wrapKey: wrapKey,
      searchController: SearchController(),
      selectedEntities: descriptor.initialValues,
    );

    super.initState();
  }

  @override
  void dispose() {
    state.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WizardItem(
      action: state.selectedEntities.isEmpty
          ? null
          : CLMenuItem(
              title: 'Save',
              icon: MdiIcons.floppy,
              onTap: () async {
                if (state.selectedEntities.isNotEmpty) {
                  widget.onDone(CLFormSelectResult(state.selectedEntities)
                      .selectedEntities as List<Tag>);
                }
                return state.selectedEntities.isNotEmpty;
              },
            ),
      child: SizedBox.expand(
        child: CLFormSelect(
          descriptors: descriptor,
          state: state,
          onRefresh: () {
            setState(() {});
          },
        ),
      ),
    );
  }

  Future<Tag?> create(BuildContext context, Tag tag) async {
    final Tag entityUpdated;
    if (tag.id == null) {
      final res = await TagEditor.popupDialog(context, tag: tag);
      if (res == null) {
        return null;
      }
      entityUpdated = res;
    } else {
      entityUpdated = tag;
    }

    return entityUpdated;
  }
}


/*
SingleChildScrollView(
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
 */