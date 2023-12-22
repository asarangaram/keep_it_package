import 'dart:math';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class UpsertCollectionForm extends ConsumerWidget {
  const UpsertCollectionForm({super.key, this.collection, this.onDone});

  final Collection? collection;
  final Function()? onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider(null));

    return collectionsAsync.when(
      loading: () => const CLLoadingView(),
      error: (err, _) => CLErrorView(
        errorMessage: err.toString(),
      ),
      data: (collections) => SizedBox(
        width: min(MediaQuery.of(context).size.width, 450),
        child: CLTextFieldForm(
          buttonLabel: (collection?.id == null) ? "Create" : "Update",
          clFormFields: [
            CLFormField(
              type: CLFormFieldTypes.textField,
              validator: (name) => validateName(
                name,
                collections.entries,
              ),
              label: "Name",
              initialValue: collection?.label ?? "",
            ),
            CLFormField(
              type: CLFormFieldTypes.textFieldMultiLine,
              validator: validateDescription,
              label: "Description",
              initialValue: collection?.description ?? "",
            )
          ],
          onSubmit: (List<String> values) {
            final label = values[0];
            final description =
                values[1].trim().isEmpty ? null : values[1].trim();

            try {
              ref.read(collectionsProvider(null).notifier).upsertCollection(
                  Collection(
                      id: collection?.id,
                      label: label.trim(),
                      description: description));
            } catch (e) {
              return e.toString();
            }

            onDone?.call();
            return null;
          },
        ),
      ),
    );
  }

  String? validateName(String? name, List<Collection> collections) {
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
    if (collections.map((e) => e.label.trim()).contains(name.trim())) {
      return "$name already exists";
    }
    return null;
  }

  String? validateDescription(String? name) {
    // No restriction as of now
    return null;
  }
}
