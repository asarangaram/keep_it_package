import 'dart:convert';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

class CollectionEditor extends StatefulWidget {
  factory CollectionEditor({
    required int collectionId,
    required void Function(CLEntity collection) onSubmit,
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
    required void Function(CLEntity collection) onSubmit,
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

  final void Function(CLEntity collection) onSubmit;
  final void Function() onCancel;
  final bool isDialog;

  @override
  State<CollectionEditor> createState() => _CollectionEditorState();

  static Future<CLEntity?> openSheet(
    BuildContext context,
    WidgetRef ref, {
    required CLEntity collection,
  }) async {
    return showShadSheet<CLEntity>(
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
}

class _CollectionEditorState extends State<CollectionEditor> {
  final formKey = GlobalKey<ShadFormState>();
  Map<Object, dynamic> formValue = {};

  Widget loading(String debugMessage) => ShadSheet(
        title: const Text('Loading'),
        description: const Text(
          'Loading Collection ',
        ),
        child: SizedBox(
          height: 100,
          child: CLLoader.widget(
            debugMessage: debugMessage,
          ),
        ),
      );
  Widget errorBuilder(Object e, StackTrace st) {
    throw UnimplementedError('errorBuilder');
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: GetCollection(
        id: widget.collectionId,
        errorBuilder: errorBuilder,
        loadingBuilder: () => loading('GetCollection'),
        builder: (collection) {
          if (collection == null) {
            try {
              throw Exception("Collection can't be null");
            } catch (e, st) {
              return errorBuilder(e, st);
            }
          }
          return GetCollectionMultiple(
            query: DBQueries.entitiesVisible, // FIXME
            errorBuilder: errorBuilder,
            loadingBuilder: () => loading('GetCollectionMultiple'),
            builder: (collections) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ShadSheet(
                  draggable: true,
                  title: Text(
                    'Edit Collection "${collection.label!.capitalizeFirstLetter()}"',
                  ),
                  description: const Text(
                    'Change the label and add/update description here',
                  ),
                  actions: [
                    ShadButton(
                      child: const Text('Save changes'),
                      onPressed: () {
                        if (formKey.currentState!.saveAndValidate()) {
                          formValue = formKey.currentState!.value;
                          final label = formValue['label'] as String;
                          final desc = formValue['description'] as String?;
                          final updated = collection.copyWith(
                            label: () => label,
                            description: () => desc == null
                                ? null
                                : desc.isEmpty
                                    ? null
                                    : desc,
                          );
                          widget.onSubmit(updated);
                        }
                      },
                    ),
                  ],
                  child: ShadForm(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShadInputFormField(
                          id: 'label',
                          // prefix: const Icon(LucideIcons.tag),
                          label: const Text(' Collection Name'),
                          initialValue: collection.label,
                          placeholder: const Text('Enter collection name'),
                          validator: (value) => validateName(
                            newLabel: value,
                            existingLabel: collection.label,
                            collections: collections,
                          ),
                          showCursor: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\n')),
                          ],
                        ),
                        ShadInputFormField(
                          id: 'description',
                          // prefix: const Icon(LucideIcons.tag),
                          label: const Text(' About'),
                          initialValue: collection.description,
                          placeholder:
                              const Text('Describe about this collection'),
                          maxLines: 4,
                        ),
                        if (formValue.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 24, left: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('FormValue', style: theme.textTheme.p),
                                const SizedBox(height: 4),
                                SelectableText(
                                  const JsonEncoder.withIndent('    ')
                                      .convert(formValue),
                                  style: theme.textTheme.small,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
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
    required List<CLEntity> collections,
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
          .map((e) => e.label!.trim().toLowerCase())
          .contains(newLabel0.toLowerCase())) {
        return '$newLabel0 already exists';
      }
    }
    return null;
  }
}
