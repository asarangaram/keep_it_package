import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

class CollectionEditor2 extends StatefulWidget {
  const CollectionEditor2({
    required this.collection,
    required this.collections,
    required this.tags,
    super.key,
    this.onDone,
  });
  final Collection collection;
  final Collections collections;
  final Tags tags;
  final void Function(Collection collection)? onDone;

  @override
  State<CollectionEditor2> createState() => _CollectionEditorState();
}

class _CollectionEditorState extends State<CollectionEditor2> {
  late List<Tag> currTags;
  late Collection currCollection;

  @override
  void initState() {
    currTags = widget.tags.entries;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final availableSuggestions = <Tag>[
      ...currTags,
      ...suggestedTags
        ..where((element) {
          return !widget.tags.entries
              .map((e) => e.label)
              .contains(element.label);
        }).toList(),
    ];
    return CLTextFieldForm(
      buttonLabel: 'Update',
      clFormFields: [
        CLFromFieldTypeText(
          type: CLFormFieldTypes.textField,
          validator: (name) => validateName(
            name,
            widget.collections.entries,
          ),
          label: 'Name',
          initialValue: widget.collection.label,
        ),
        CLFromFieldTypeText(
          type: CLFormFieldTypes.textFieldMultiLine,
          validator: validateDescription,
          label: 'Description',
          initialValue: widget.collection.description ?? '',
        ),
        CLFromFieldTypeSelector(
          type: CLFormFieldTypes.selector,
          initialEntries: currTags,
          getSuggestions: (context, searchTerm) {
            return availableSuggestions;
          },
          hasMatchingSuggestion: (context, searcTerm) {
            final c = availableSuggestions
                .where((e) => e.label == searcTerm)
                .firstOrNull;
            return false;
          },
          buildLabel: (item) => (item as Tag).label,
          buildDescription: (item) => (item as Tag).description,
          onSelectSuggestion: (context, item) {
            final tag = item as Tag;
            currTags.add(tag);
            setState(() {});
          },
          onCreate: (context, newLabel) {
            // TODO: Create and add Tag
            print('create new Tag $newLabel');
          },
          removeItem: (context, item) {
            currTags.remove(item as Tag);
            setState(() {});
          },
        ),
      ],
      onSubmit: (List<String> values) {
        final label = values[0];
        final description = values[1].trim().isEmpty ? null : values[1].trim();

        try {
          widget.onDone?.call(
            Collection(
              id: widget.collection.id,
              label: label.trim(),
              description: description,
            ),
          );
        } catch (e) {
          return null;
        }

        return null;
      },
    );
  }

  String? validateName(String? name, List<Collection> tags) {
    if (name?.isEmpty ?? true) {
      return "Name can't be empty";
    }
    /* if (name!.length > 16) {
      return 'Name should not exceed 15 letters';
    } */
    if (widget.collection.label == name) {
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
