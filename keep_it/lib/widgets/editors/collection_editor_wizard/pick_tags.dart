import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import '../tag_editor.dart';

class PickTags extends StatelessWidget {
  const PickTags({
    required this.collection,
    required this.onDone,
    super.key,
  });
  final Collection collection;
  final void Function(List<Tag>) onDone;

  @override
  Widget build(BuildContext context) {
    return LoadTags(
      buildOnData: (existingTags) {
        return LoadTags(
          collectionId: collection.id,
          buildOnData: (currentTags) {
            return CLWizardFormField(
              actionMenu: (context, onTap) => CLMenuItem(
                icon: MdiIcons.floppy,
                title: 'Save',
                onTap: onTap,
              ),
              descriptor: CLFormSelectMultipleDescriptors(
                title: 'Tags',
                label: 'Select Tags',
                labelBuilder: (e) => (e as Tag).label,
                descriptionBuilder: (e) => (e as Tag).description,
                suggestionsAvailable: [
                  ...existingTags.entries,
                  ...suggestedTags.excludeByLabel(
                    existingTags.entries,
                    (Tag e) => e.label,
                  ),
                ],
                initialValues: collection.id == null ? [] : currentTags.entries,
                onSelectSuggestion: (item) => createTag(context, item as Tag),
                onCreateByLabel: (label) =>
                    createTag(context, Tag(label: label)),
              ),
              onSubmit: (CLFormFieldResult result) async {
                onDone(
                  (result as CLFormSelectMultipleResult)
                      .selectedEntities
                      .map((e) => e as Tag)
                      .toList(),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Tag?> createTag(BuildContext context, Tag tag) async {
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
