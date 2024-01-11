import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:keep_it/pages/views/collections_page/add_collection_form.dart';
import 'package:keep_it/pages/views/collections_page/collections_list.dart';
import 'package:keep_it/pages/views/load_from_store/load_from_store.dart';
import 'package:keep_it/pages/views/main/background.dart';
import 'package:store/store.dart';

class KeepItDialogs {
  static Future<void> upsertCollection(
    BuildContext context, {
    Collection? collection,
    void Function()? onDone,
  }) =>
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CLDialogWrapper(
            onCancel: () {
              Navigator.of(context).pop();
            },
            child: UpsertCollectionForm(
              collection: collection,
              onDone: () {
                Navigator.of(context).pop();
                onDone?.call();
              },
            ),
          );
        },
      );

  static Widget _selectCollections(
    BuildContext context,
    List<Collection> collections, {
    required dynamic Function(List<Collection>) onSelectionDone,
    String? labelSelected,
    String? labelNoneSelected,
  }) {
    if (collections.isEmpty) {
      throw Exception("CollectionList can't be empty!");
    }

    return CLBackground(
      brighnessFactor: collections.isNotEmpty ? 0.25 : 0,
      child: CLDialogWrapper(
        backgroundColor: Colors.transparent,
        onCancel: () {
          Navigator.of(context).pop();
        },
        child: CLSelectionWrapper(
          selectableList: collections,
          multiSelection: true,
          onSelectionDone: (selectedIndices) {
            onSelectionDone(
              selectedIndices.map((e) => collections[e]).toList(),
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
              collectionList: selectableList,
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
    List<Collection>? collectionList,
    String? labelSelected,
    String? labelNoneSelected,
  }) =>
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          if (collectionList != null) {
            return CLBackground(
              brighnessFactor: 0.25,
              child: _selectCollections(
                context,
                collectionList,
                onSelectionDone: onSelectionDone,
                labelSelected: labelSelected,
                labelNoneSelected: labelNoneSelected,
              ),
            );
          }
          return LoadCollections(
            buildOnData: (collectionFromDB) => _selectCollections(
              context,
              collectionFromDB.entries,
              onSelectionDone: onSelectionDone,
              labelSelected: labelSelected,
              labelNoneSelected: labelNoneSelected,
            ),
          );
        },
      );

  static void onSuggestions(
    BuildContext context, {
    required dynamic Function(List<Collection>) onSelectionDone,
    List<Collection>? availableSuggestions,
  }) {
    selectCollections(
      context,
      collectionList: availableSuggestions,
      onSelectionDone: onSelectionDone,
      labelNoneSelected: 'Select from Suggestions',
      labelSelected: 'Create Selected',
    );
  }

  // Not used
  /* onCreateNewCollection(BuildContext context,
          Function({Function()? onDone}) handleCreateNew) =>
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CLButtonsGrid.dialog(
            onCancel: () {
              Navigator.of(context).pop();
            },
            children2D: [
              [
                CLMenuItem("Suggested\nCollections", Icons.menu),
                CLMenuItem("Create New", Icons.new_label, onTap: () {
                  upsertCollection(context, onDone: () {
                    Navigator.of(context).pop();
                  });
                }),
              ],
            ],
          );
        },
      ); */
}
