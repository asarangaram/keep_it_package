import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

import 'add_tag_form.dart';
import 'from_store/from_store.dart';
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

  static Widget _selectTags(
    BuildContext context,
    Tags tags, {
    required dynamic Function(List<Tag>) onSelectionDone,
    required String title,
    String? labelSelected,
    String? labelNoneSelected,
    bool showCount = true,
  }) {
    if (tags.isEmpty) {
      throw Exception("TagList can't be empty!");
    }

    return CLBackground(
      child: CLDialogWrapper(
        backgroundColor: Colors.transparent,
        onCancel: () {
          Navigator.of(context).pop();
        },
        child: CLSelectionWrapper(
          title: title,
          selectableList: tags.entries,
          multiSelection: true,
          onSelectionDone: (selectedIndices) {
            onSelectionDone(
              selectedIndices.map((e) => tags.entries[e]).toList(),
            );

            Navigator.of(context).pop();
          },
          labelNoneSelected: labelNoneSelected,
          labelSelected: labelSelected,
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
              showCount: showCount,
            );
          },
        ),
      ),
    );
  }

  static Future<void> selectTags(
    BuildContext context, {
    required void Function(List<Tag>) onSelectionDone,
    String? labelSelected,
    String? labelNoneSelected,
  }) =>
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return LoadTags(
            buildOnData: (tagFromDB) => _selectTags(
              context,
              tagFromDB,
              onSelectionDone: onSelectionDone,
              labelSelected: labelSelected,
              labelNoneSelected: labelNoneSelected,
              title: 'Save Into...',
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
          child: _selectTags(
            context,
            availableSuggestions,
            onSelectionDone: onSelectionDone,
            labelSelected: 'Create Selected',
            labelNoneSelected: 'Select from Suggestions',
            title: 'Suggestions',
            showCount: false,
          ),
        );
      },
    );
  }
}
