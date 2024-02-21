import 'dart:math';

import 'package:flutter/material.dart';
import 'package:store/store.dart';

import '../modules/shared_media/dialogs/dialogs.dart';
import '../modules/shared_media/keep_media_wizard/keepit_selector.dart';
import '../modules/shared_media/keep_media_wizard/selector.dart';
import '../widgets/collection/colletion_editor.dart';

class EditCollectionPage extends StatelessWidget {
  const EditCollectionPage({
    required this.collectionID,
    super.key,
  });

  final int collectionID;

  @override
  Widget build(BuildContext context) {
    return LoadTags(
      collectionID: collectionID,
      buildOnData: (tags) {
        return LoadCollections(
          buildOnData: (collections) => SizedBox(
            width: min(MediaQuery.of(context).size.width, 450),
            child: CollectionEditor(
              collection:
                  // getByID
                  collections.entries.where((e) => e.id == collectionID).first,
              collections: collections,
              tags: tags,
            ),
          ),
        );
      },
    );
  }
}

class CollectionEditor extends StatefulWidget {
  const CollectionEditor({
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
  State<CollectionEditor> createState() => _CollectionEditorState();
}

class _CollectionEditorState extends State<CollectionEditor> {
  @override
  Widget build(BuildContext context) {
    return Selector(
      entities: widget.tags.entries,
      availableSuggestions: suggestedTags,
      onDone: (selectedTags) {},
      onCreateByLabel: (label) async {
        return create(Tag(label: label));
      },
      onSelect: (Object item) async {
        return create(item as Tag);
      },
      labelBuilder: (e) => (e as Tag).label,
      descriptionBuilder: (e) => (e as Tag).description,
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
}
