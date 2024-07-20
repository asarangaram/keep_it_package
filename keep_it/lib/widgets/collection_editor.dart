import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';

class CollectionEditor extends StatelessWidget {
  factory CollectionEditor({
    required int collectionId,
    required void Function(Collection collection) onSubmit,
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
    required void Function(Collection collection) onSubmit,
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

  final void Function(Collection collection) onSubmit;
  final void Function() onCancel;
  final bool isDialog;

  @override
  Widget build(BuildContext context) {
    return CLDialogWrapper(
      onCancel: isDialog ? onCancel : null,
      child: GetCollectionMultiple(
        buildOnData: (List<Collection> collections) {
          final collection =
              collections.where((e) => e.id == collectionId).first;
          return CLForm(
            explicitScrollDownOption: !isDialog,
            descriptors: {
              'label': CLFormTextFieldDescriptor(
                title: 'Name',
                label: 'Collection Name',
                initialValue: collection.label,
                onValidate: (value) => Collection.validateName(
                  newLabel: value,
                  existingLabel: collection.label,
                  collections: collections,
                ),
              ),
              'description': CLFormTextFieldDescriptor(
                title: 'About',
                label: 'Describe about this collection',
                initialValue: collection.description ?? '',
                onValidate: (value) => Collection.validateDescription(
                  description: value,
                  existingDescription: collection.description,
                  collections: collections,
                ),
                maxLines: 4,
              ),
            },
            onSubmit: (result) async {
              final label = (result['label']! as CLFormTextFieldResult).value;
              final desc =
                  (result['description']! as CLFormTextFieldResult).value;

              final updated = collection.copyWith(
                label: label,
                description: desc.isEmpty ? null : desc,
              );

              onSubmit(updated);
            },
            onCancel: isDialog ? null : onCancel,
          );
        },
      ),
    );
  }

  static Future<Collection?> popupDialog(
    BuildContext context, {
    required Collection collection,
  }) async =>
      showDialog<Collection>(
        context: context,
        builder: (BuildContext context) => CollectionEditor.dialog(
          collectionId: collection.id!,
          onSubmit: (collection) {
            Navigator.of(context).pop(collection);
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      );
}
