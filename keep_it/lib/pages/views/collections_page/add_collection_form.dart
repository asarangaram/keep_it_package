import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/models/collection.dart';
import 'package:keep_it/providers/db_store.dart';

import '../../../models/collections.dart';
import '../../../providers/theme.dart';

class UpsertCollectionForm extends ConsumerWidget {
  const UpsertCollectionForm(
      {super.key, required this.collections, this.collection, this.onDone});
  final Collections collections;
  final Collection? collection;
  final Function()? onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    List<CLFormField> clFormFields = [
      CLFormField(
        type: CLFormFieldTypes.textField,
        validator: (name) => validateName(name),
        label: "Name",
        initialValue: collection?.label ?? "",
      ),
      CLFormField(
        type: CLFormFieldTypes.textFieldMultiLine,
        validator: validateDescription,
        label: "Description",
        initialValue: collection?.description ?? "",
      )
    ];

    return CLTextFieldForm(
      buttonLabel: (collection?.id == null) ? "Create" : "Update",
      clFormFields: clFormFields,
      onCancel: () {
        Navigator.of(context).pop();
        onDone?.call();
      }, // Close the dialog},
      onSubmit: (List<String> values) {
        final label = values[0];
        final description = values[1].trim().isEmpty ? null : values[1].trim();

        try {
          ref.read(collectionsProvider(null).notifier).upsertCollection(
              Collection(
                  id: collection?.id,
                  label: label.trim(),
                  description: description));
        } catch (e) {
          return e.toString();
        }
        Navigator.of(context).pop(); // Close the dialog
        onDone?.call();
        return null;
      },
      foregroundColor: theme.colorTheme.textColor,
      backgroundColor: theme.colorTheme.overlayBackgroundColor,
      disabledColor: theme.colorTheme.disabledColor,
      errorColor: theme.colorTheme.errorColor,
    );
  }

  String? validateName(String? name) {
    if (name?.isEmpty ?? true) {
      return "Name can't be empty";
    }
    if (name!.length > 16) {
      return "Name should not exceed 15 letters";
    }
    if (collection?.label == name) {
      // Nothing changed.
      return null;
    }
    if (collections.collections
        .map((e) => e.label.trim())
        .contains(name.trim())) {
      return "$name already exists";
    }
    return null;
  }

  String? validateDescription(String? name) {
    // No restriction as of now
    return null;
  }
}
