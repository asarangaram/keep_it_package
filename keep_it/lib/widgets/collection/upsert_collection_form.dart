import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class CollectionEditor extends ConsumerWidget {
  const CollectionEditor({super.key, this.collection, this.onDone});

  final Collection? collection;
  final void Function(Collection collection)? onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoadCollections(
      buildOnData: (collections) => SizedBox(
        width: min(MediaQuery.of(context).size.width, 450),
        child: CLTextFieldForm(
          buttonLabel: (collection?.id == null) ? 'Create' : 'Update',
          clFormFields: [
            CLFromFieldTypeText(
              type: CLFormFieldTypes.textField,
              validator: (name) => validateName(
                name,
                collections.entries,
              ),
              label: 'Name',
              initialValue: collection?.label ?? '',
            ),
            CLFromFieldTypeText(
              type: CLFormFieldTypes.textFieldMultiLine,
              validator: validateDescription,
              label: 'Description',
              initialValue: collection?.description ?? '',
            ),
            CLFromFieldTypeSelector(
              type: CLFormFieldTypes.selector,
              initialEntries: [],
              getSuggestions: (searchTerm) {
                return [];
              },
              hasMatchingSuggestion: (searcTerm) {
                return false;
              },
              buildLabel: (item) => (item as Tag).label,
              buildDescription: (item) => (item as Tag).description,
              onSelectSuggestion: (item) {},
              onCreate: (newLabel) {},
            ),
          ],
          onSubmit: (List<String> values) {
            final label = values[0];
            final description =
                values[1].trim().isEmpty ? null : values[1].trim();

            try {
              onDone?.call(
                Collection(
                  id: collection?.id,
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

  String? validateName(String? name, List<Collection> tags) {
    if (name?.isEmpty ?? true) {
      return "Name can't be empty";
    }
    /* if (name!.length > 16) {
      return 'Name should not exceed 15 letters';
    } */
    if (collection?.label == name) {
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
