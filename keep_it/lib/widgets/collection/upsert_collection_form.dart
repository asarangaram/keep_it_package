import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class UpsertCollectionForm extends ConsumerWidget {
  const UpsertCollectionForm({super.key, this.entity, this.onDone});

  final Collection? entity;
  final void Function(Collection tag)? onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider(null));

    return tagsAsync.when(
      loading: () => const CLLoadingView(),
      error: (err, _) => CLErrorView(
        errorMessage: err.toString(),
      ),
      data: (tags) => SizedBox(
        width: min(MediaQuery.of(context).size.width, 450),
        child: CLTextFieldForm(
          buttonLabel: (entity?.id == null) ? 'Create' : 'Update',
          clFormFields: [
            CLFormField(
              type: CLFormFieldTypes.textField,
              validator: (name) => validateName(
                name,
                tags.entries,
              ),
              label: 'Name',
              initialValue: entity?.label ?? '',
            ),
            CLFormField(
              type: CLFormFieldTypes.textFieldMultiLine,
              validator: validateDescription,
              label: 'Description',
              initialValue: entity?.description ?? '',
            ),
          ],
          onSubmit: (List<String> values) {
            final label = values[0];
            final description =
                values[1].trim().isEmpty ? null : values[1].trim();

            try {
              onDone?.call(
                Collection(
                  id: entity?.id,
                  label: label.trim(),
                  description: description,
                ),
              );
            } catch (e) {
              return null;
            }

            return null;
          },
        ),
      ),
    );
  }

  String? validateName(String? name, List<Tag> tags) {
    if (name?.isEmpty ?? true) {
      return "Name can't be empty";
    }
    /* if (name!.length > 16) {
      return 'Name should not exceed 15 letters';
    } */
    if (entity?.label == name) {
      // Nothing changed.
      return null;
    }
    if (tags.map((e) => e.label.trim()).contains(name!.trim())) {
      return '$name already exists';
    }
    return null;
  }

  String? validateDescription(String? name) {
    // No restriction as of now
    return null;
  }
}
