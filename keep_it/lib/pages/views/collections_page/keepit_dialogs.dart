import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:store/store.dart';

import '../../../data/db_default_collections.dart';
import '../main/background.dart';
import 'add_collection_form.dart';
import '../load_from_store/load_collections.dart';
import 'collections_list.dart';

class KeepItDialogs {
  static upsertCollection(
    BuildContext context, {
    Collection? collection,
    Function()? onDone,
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
              ));
        },
      );

  static Widget _selectCollections(
    BuildContext context,
    List<Collection> collections, {
    required dynamic Function(List<Collection>) onSelectionDone,
  }) {
    if (collections.isEmpty) {
      throw Exception("CollectionList can't be empty!");
    }
    return CLBackground(
      brighnessFactor: collections.isNotEmpty ? 0.25 : 0,
      child: CLDialogWrapper(
        backgroundColor: Colors.transparent,
        isDialog: true,
        onCancel: () {
          Navigator.of(context).pop();
        },
        child: CLSelectionWrapper(
          selectableList: collections,
          multiSelection: true,
          onSelectionDone: (selectedIndices) {
            onSelectionDone(
                selectedIndices.map((e) => collections[e]).toList());

            Navigator.of(context).pop();
          },
          listBuilder: (
              {required onSelection,
              required selectableList,
              required selectionMask}) {
            if (selectableList.isEmpty) {
              throw Exception("CollectionList can't be empty!");
            }
            return CollectionsList(
              collectionList: selectableList as List<Collection>,
              selectionMask: selectionMask,
              onSelection: onSelection,
            );
          },
        ),
      ),
    );
  }

  static selectCollections(
    BuildContext context, {
    List<Collection>? collectionList,
    required Function(List<Collection>) onSelectionDone,
  }) =>
      showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            if (collectionList != null) {
              return CLBackground(
                brighnessFactor: 0.25,
                child: _selectCollections(context, collectionList,
                    onSelectionDone: (_) {
                  onSelectionDone(_);
                }),
              );
            }
            return LoadCollections(
              buildOnData: (collectionFromDB) => _selectCollections(
                  context, collectionFromDB.entries, onSelectionDone: (_) {
                onSelectionDone(_);
              }),
            );
          });

  static void onSuggestions(
    context, {
    required dynamic Function(List<Collection>) onSelectionDone,
  }) =>
      selectCollections(context,
          collectionList: defaultCollections, onSelectionDone: (_) {});

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
