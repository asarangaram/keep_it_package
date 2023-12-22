import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

import 'add_collection_form.dart';

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
