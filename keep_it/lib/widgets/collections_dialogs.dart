import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:store/store.dart';

import 'add_collection_form.dart';
import 'collections_list.dart';
import 'from_store/from_store.dart';

class CollectionsDialog {
  static Future<bool?> newCollection(
    BuildContext context,
  ) {
    return _upsertCollection(
      context,
    );
  }

  static Future<bool?> updateCollection(
    BuildContext context,
    Collection? collection,
  ) {
    return _upsertCollection(context, collection: collection);
  }

  static Future<bool?> _upsertCollection(
    BuildContext context, {
    Collection? collection,
    //  void Function()? onDone,
  }) async =>
      showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return CLDialogWrapper(
            onCancel: () => Navigator.of(context).pop(false),
            child: UpsertCollectionForm(
              collection: collection,
              onDone: () => Navigator.of(context).pop(true),
            ),
          );
        },
      );

  static Widget _selectCollections(
    BuildContext context,
    Collections collections, {
    required dynamic Function(List<Collection>) onSelectionDone,
    required String title,
    String? labelSelected,
    String? labelNoneSelected,
  }) {
    if (collections.isEmpty) {
      throw Exception("CollectionList can't be empty!");
    }

    return CLBackground(
      child: CLDialogWrapper(
        backgroundColor: Colors.transparent,
        onCancel: () {
          Navigator.of(context).pop();
        },
        child: CLSelectionWrapper(
          title: title,
          selectableList: collections.entries,
          multiSelection: true,
          onSelectionDone: (selectedIndices) {
            onSelectionDone(
              selectedIndices.map((e) => collections.entries[e]).toList(),
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
              throw Exception("CollectionList can't be empty!");
            }
            return CollectionsList(
              collections: Collections(selectableList),
              selectionMask: selectionMask,
              onSelection: onSelection,
            );
          },
        ),
      ),
    );
  }

  static Future<void> selectCollections(
    BuildContext context, {
    required void Function(List<Collection>) onSelectionDone,
    String? labelSelected,
    String? labelNoneSelected,
  }) =>
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return LoadCollections(
            buildOnData: (collectionFromDB) => _selectCollections(
              context,
              collectionFromDB,
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
    required dynamic Function(List<Collection>) onSelectionDone,
    required Collections availableSuggestions,
  }) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CLBackground(
          child: _selectCollections(
            context,
            availableSuggestions,
            onSelectionDone: onSelectionDone,
            labelSelected: 'Create Selected',
            labelNoneSelected: 'Select from Suggestions',
            title: 'Suggestions',
          ),
        );
      },
    );
  }
}
