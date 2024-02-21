import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'upsert_collection_form.dart';

class CollectionsDialog {
  static Future<Collection?> upsert(
    BuildContext context, {
    Collection? entity,
    //  void Function()? onDone,
  }) async =>
      showDialog<Collection>(
        context: context,
        builder: (BuildContext context) {
          return CLDialogWrapper(
            onCancel: () => Navigator.of(context).pop(),
            child: UpsertCollectionForm(
              entity: entity,
              onDone: (Collection entity) {
                Navigator.of(context).pop(entity);
              },
            ),
          );
        },
      );

  /* static void onSuggestions(
    BuildContext context, {
    required dynamic Function(List<Tag>) onSelectionDone,
    required Tags availableSuggestions,
  }) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CLDialogWrapper(
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
        );
      },
    ); 
  }*/

  static Future<bool> onAddItemsIntoCollection(
    BuildContext context,
    WidgetRef ref,
    Collection collection,
  ) async {
    return onPickFiles(context, ref, collectionId: collection.id);
  }
}
