import 'dart:math';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class UpsertTagForm extends ConsumerWidget {
  const UpsertTagForm({super.key, this.tag, this.onDone});

  final Tag? tag;
  final void Function(Tag tag)? onDone;

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
          buttonLabel: (tag?.id == null) ? 'Create' : 'Update',
          clFormFields: [
            CLFormField(
              type: CLFormFieldTypes.textField,
              validator: (name) => validateName(
                name,
                tags.entries,
              ),
              label: 'Name',
              initialValue: tag?.label ?? '',
            ),
            CLFormField(
              type: CLFormFieldTypes.textFieldMultiLine,
              validator: validateDescription,
              label: 'Description',
              initialValue: tag?.description ?? '',
            ),
          ],
          onSubmit: (List<String> values) {
            final label = values[0];
            final description =
                values[1].trim().isEmpty ? null : values[1].trim();

            try {
              final tagWithID = ref.read(tagsProvider(null).notifier).upsertTag(
                    Tag(
                      id: tag?.id,
                      label: label.trim(),
                      description: description,
                    ),
                  );
              onDone?.call(tagWithID);
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
    if (tag?.label == name) {
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
