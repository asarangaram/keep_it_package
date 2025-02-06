import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_factory/form_factory.dart';
import 'package:store/store.dart';

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
      child: GetCollection(
        id: collectionId,
        errorBuilder: (_, __) {
          throw UnimplementedError('errorBuilder');
        },
        loadingBuilder: () => CLLoader.widget(
          debugMessage: 'GetCollection',
        ),
        builder: (collection) {
          if (collection == null) {
            throw Exception('Collection with id $collectionId not found');
          }
          return GetCollectionMultiple(
            query: DBQueries.collections,
            errorBuilder: (_, __) {
              throw UnimplementedError('errorBuilder');
            },
            loadingBuilder: () => CLLoader.widget(
              debugMessage: 'GetCollectionMultiple',
            ),
            builder: (collections) {
              return CLForm(
                explicitScrollDownOption: !isDialog,
                descriptors: {
                  'label': CLFormTextFieldDescriptor(
                    title: 'Name',
                    label: 'Collection Name',
                    initialValue: collection.label,
                    onValidate: (value) => validateName(
                      newLabel: value,
                      existingLabel: collection.label,
                      collections: collections.entries,
                    ),
                  ),
                  'description': CLFormTextFieldDescriptor(
                    title: 'About',
                    label: 'Describe about this collection',
                    initialValue: collection.description ?? '',
                    onValidate: (_) => null,
                    maxLines: 4,
                  ),
                },
                onSubmit: (result) async {
                  final label =
                      (result['label']! as CLFormTextFieldResult).value;
                  final desc =
                      (result['description']! as CLFormTextFieldResult).value;

                  final updated = collection.copyWith(
                    label: label,
                    description: () => desc.isEmpty ? null : desc,
                  );

                  onSubmit(updated);
                },
                onCancel: isDialog ? null : onCancel,
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

    if (newLabel0 == null) {
      return "Name can't be empty";
    } else {
      if (newLabel0.isEmpty) {
        return "Name can't be empty";
      }
      if (existingLabel?.trim().toLowerCase() == newLabel0.toLowerCase()) {
        // Nothing changed.
        return null;
      }
      if (collections
          .map((e) => e.label.trim().toLowerCase())
          .contains(newLabel0.toLowerCase())) {
        return '$newLabel0 already exists';
      }
    }
    return null;
  }

  static Future<Collection?> popupDialog(
    BuildContext context,
    WidgetRef ref, {
    required Collection collection,
  }) async =>
      showDialog<Collection>(
        context: context,
        builder: (BuildContext context) => CollectionEditor.dialog(
          collectionId: collection.id!,
          onSubmit: (collection) {
            PageManager.of(context).pop(collection);
          },
          onCancel: () => PageManager.of(context).pop(),
        ),
      );
}
