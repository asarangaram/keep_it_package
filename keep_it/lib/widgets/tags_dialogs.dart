import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

import 'add_tag_form.dart';
import 'tags_list.dart';

class KeepItDialogs {
  static Future<CollectionBase?> upsert(
    BuildContext context, {
    CollectionBase? entity,
    //  void Function()? onDone,
  }) async =>
      showDialog<CollectionBase>(
        context: context,
        builder: (BuildContext context) {
          return CLDialogWrapper(
            onCancel: () => Navigator.of(context).pop(),
            child: UpsertEntityForm(
              entity: entity,
              onDone: (CollectionBase entity) {
                Navigator.of(context).pop(entity);
              },
            ),
          );
        },
      );

  static void onSuggestions(
    BuildContext context, {
    required dynamic Function(List<Tag>) onSelectionDone,
    required Tags availableSuggestions,
  }) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CLBackground(
          child: CLBackground(
            child: CLDialogWrapper(
              backgroundColor: Colors.transparent,
              onCancel: () {
                Navigator.of(context).pop();
              },
              child: CLSelectionWrapper(
                title: 'Suggestions',
                selectableList: availableSuggestions.entries,
                multiSelection: true,
                onSelectionDone: (selectedIndices) {
                  onSelectionDone(
                    selectedIndices
                        .map((e) => availableSuggestions.entries[e])
                        .toList(),
                  );

                  Navigator.of(context).pop();
                },
                labelNoneSelected: 'Select from Suggestions',
                labelSelected: 'Create Selected',
                listBuilder: ({
                  required onSelection,
                  required selectableList,
                  required selectionMask,
                }) {
                  if (selectableList.isEmpty) {
                    throw Exception("TagList can't be empty!");
                  }
                  return TagsList(
                    tags: Tags(selectableList),
                    selectionMask: selectionMask,
                    onSelection: onSelection,
                    showCount: false,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
/*
_selectTags(
            context,
            availableSuggestions,
            onSelectionDone: onSelectionDone,
            labelSelected: 'Create Selected',
            labelNoneSelected: 'Select from Suggestions',
            title: 'Suggestions',
            showCount: false,
          ),
*/
