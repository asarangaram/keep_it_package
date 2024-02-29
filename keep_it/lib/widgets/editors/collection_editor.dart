import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';

import 'package:keep_it/widgets/editors/tag_editor.dart';
import 'package:store/store.dart';

class CollectionEditor extends StatelessWidget {
  factory CollectionEditor({
    required int collectionId,
    required void Function(Collection collection, List<Tag> tags) onSubmit,
    required void Function() onCancel,
    Key? key,
  }) {
    return CollectionEditor._(
      collectionId: collectionId,
      onSubmit: onSubmit,
      onCancel: onCancel,
      isDialog: false,
      key: key,
    );
  }
  factory CollectionEditor.dialog({
    required int collectionId,
    required void Function(Collection collection, List<Tag> tags) onSubmit,
    required void Function() onCancel,
    Key? key,
  }) {
    return CollectionEditor._(
      collectionId: collectionId,
      onSubmit: onSubmit,
      onCancel: onCancel,
      isDialog: true,
      key: key,
    );
  }
  const CollectionEditor._({
    required this.collectionId,
    required this.isDialog,
    required this.onSubmit,
    required this.onCancel,
    super.key,
  });

  final int collectionId;

  final void Function(Collection collection, List<Tag> tags) onSubmit;
  final void Function() onCancel;
  final bool isDialog;

  @override
  Widget build(BuildContext context) {
    return CLDialogWrapper(
      onCancel: isDialog ? onCancel : null,
      child: GetCollectionMultiple(
        buildOnData: (collections) {
          final collection =
              collections.where((e) => e.id == collectionId).first;
          return GetTagMultiple(
            buildOnData: (existingTags) {
              return GetTagMultiple(
                collectionId: collection.id,
                buildOnData: (currentTags) {
                  return CLForm(
                    explicitScrollDownOption: !isDialog,
                    descriptors: {
                      'label': CLFormTextFieldDescriptor(
                        title: 'Name',
                        label: 'Collection Name',
                        initialValue: collection.label,
                        validator: (value) => validateName(
                          newLabel: value,
                          existingLabel: collection.label,
                          collections: collections,
                        ),
                      ),
                      'description': CLFormTextFieldDescriptor(
                        title: 'About',
                        label: 'Describe about this collection',
                        initialValue: collection.description ?? '',
                        validator: (_) => null,
                        maxLines: 4,
                      ),
                      'tags': CLFormSelectMultipleDescriptors(
                        title: 'Tags',
                        label: 'Select Tags',
                        suggestionsAvailable: [
                          ...existingTags,
                          ...suggestedTags.excludeByLabel(
                            existingTags,
                            (Tag e) => e.label,
                          ),
                        ],
                        initialValues: collection.id == null ? [] : currentTags,
                        labelBuilder: (e) => (e as Tag).label,
                        descriptionBuilder: (e) => (e as Tag).description,
                        onSelectSuggestion: (Object item) async {
                          return create(context, item as Tag);
                        },
                        onCreateByLabel: (label) async {
                          return create(context, Tag(label: label));
                        },
                      ),
                    },
                    onSubmit: (result) async {
                      final label =
                          (result['label']! as CLFormTextFieldResult).value;
                      final desc =
                          (result['description']! as CLFormTextFieldResult)
                              .value;

                      final updated = collection.copyWith(
                        label: label,
                        description: desc.isEmpty ? null : desc,
                      );
                      final tags =
                          (result['tags']! as CLFormSelectMultipleResult)
                              .selectedEntities
                              .map((e) => e as Tag)
                              .toList();
                      onSubmit(updated, tags);
                    },
                    onCancel: isDialog ? null : onCancel,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String? validateName({
    required String? newLabel,
    required String? existingLabel,
    required List<Collection> collections,
  }) {
    final newLabel0 = newLabel?.trim();

    if (newLabel0?.isEmpty ?? true) {
      return "Name can't be empty";
    }

    if (existingLabel?.trim() == newLabel0) {
      // Nothing changed.
      return null;
    }
    if (collections.map((e) => e.label.trim()).contains(newLabel0)) {
      return '$newLabel0 already exists';
    }
    return null;
  }

  Future<Tag?> create(BuildContext context, Tag tag) async {
    final Tag entityUpdated;
    if (tag.id == null) {
      final res = await TagEditor.popupDialog(context, tag: tag);
      if (res == null) {
        return null;
      }
      entityUpdated = res;
    } else {
      entityUpdated = tag;
    }

    return entityUpdated;
  }

  static Future<(Collection, List<Tag>)?> popupDialog(
    BuildContext context, {
    required Collection collection,
  }) async =>
      showDialog<(Collection, List<Tag>)>(
        context: context,
        builder: (BuildContext context) => CollectionEditor.dialog(
          collectionId: collection.id!,
          onSubmit: (collection, tags) {
            Navigator.of(context).pop((collection, tags));
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      );
}
