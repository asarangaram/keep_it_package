import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';
import 'package:go_router/go_router.dart';

import 'package:store/store.dart';

import '../modules/shared_media/dialogs/dialogs.dart';

class EditCollectionPage extends StatelessWidget {
  const EditCollectionPage({
    required this.collectionID,
    super.key,
  });

  final int collectionID;

  @override
  Widget build(BuildContext context) {
    return LoadTags(
      buildOnData: (existingTags) {
        return LoadTags(
          collectionID: collectionID,
          buildOnData: (currentTags) {
            return LoadCollections(
              buildOnData: (collections) => SizedBox(
                width: min(MediaQuery.of(context).size.width, 450),
                child: CollectionEditor(
                  collection:
                      // getByID
                      collections.entries
                          .where((e) => e.id == collectionID)
                          .first,
                  collections: collections,
                  existingTags: existingTags,
                  currentTags: currentTags,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class CollectionEditor extends StatefulWidget {
  const CollectionEditor({
    required this.collection,
    required this.collections,
    required this.existingTags,
    required this.currentTags,
    super.key,
    this.onDone,
  });
  final Collection collection;
  final Collections collections;
  final Tags existingTags;
  final Tags currentTags;
  final void Function(Collection collection)? onDone;

  @override
  State<CollectionEditor> createState() => _CollectionEditorState();
}

class _CollectionEditorState extends State<CollectionEditor> {
  @override
  Widget build(BuildContext context) {
    return CLForm(
      descriptors: {
        'label': CLFormTextFieldDescriptor(
          title: 'Name',
          label: 'Collection Name',
          initialValue: widget.collection.label,
          validator: validateName,
          hint: 'Collection Name',
        ),
        'description': CLFormTextFieldDescriptor(
          title: 'About',
          label: 'Describe about this collection',
          initialValue: widget.collection.description ?? '',
          validator: (_) => null,
          hint: 'Collection Name',
          maxLines: 4,
        ),
        'tags': CLFormSelectDescriptors(
          title: 'Tags',
          label: 'Select Tags',
          suggestionsAvailable: [
            ...widget.existingTags.entries,
            ...suggestedTags.excludeByLabel(
              widget.existingTags.entries,
              (e) => e.label,
            ),
          ],
          initialValues: widget.currentTags.entries,
          labelBuilder: (e) => (e as Tag).label,
          descriptionBuilder: (e) => (e as Tag).description,
          onSelectSuggestion: (Object item) async {
            return create(item as Tag);
          },
          onCreateByLabel: (label) async {
            return create(Tag(label: label));
          },
        ),
      },
      onSubmit: (result) async {
        print(result);
        if (context.canPop()) {
          context.pop();
        }
      },
      onCancel: () {
        if (context.canPop()) {
          context.pop();
        }
      },
    );
  }

  Future<Tag?> create(Tag tag) async {
    final Tag entityUpdated;
    if (tag.id == null) {
      final res = await TagsDialog.upsert(context, entity: tag);
      if (res == null) {
        return null;
      }
      entityUpdated = res;
    } else {
      entityUpdated = tag;
    }
    return entityUpdated;
  }

  String? validateName(String? name) {
    if (name?.isEmpty ?? true) {
      return "Name can't be empty";
    }

    if (widget.collection.label == name) {
      // Nothing changed.
      return null;
    }
    if (widget.collections.entries
        .map((e) => e.label.trim())
        .contains(name!.trim())) {
      return '$name already exists';
    }
    return null;
  }
}
