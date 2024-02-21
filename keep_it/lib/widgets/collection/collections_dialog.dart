import 'package:app_loader/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';


class CollectionsDialog {
  /* static Future<Collection?> upsert(
    BuildContext context, {
    required Collection entity,
    //  void Function()? onDone,
  }) async =>
      showDialog<Collection>(
        context: context,
        builder: (BuildContext context) {
          return CLDialogWrapper(
            onCancel: () => Navigator.of(context).pop(),
            child: CollectionEditor(
              collection: entity,
              onDone: (Collection entity) {
                Navigator.of(context).pop(entity);
              },
            ),
          );
        },
      ); */

  static Future<bool> onAddItemsIntoCollection(
    BuildContext context,
    WidgetRef ref,
    Collection collection,
  ) async {
    return onPickFiles(context, ref, collectionId: collection.id);
  }
}
