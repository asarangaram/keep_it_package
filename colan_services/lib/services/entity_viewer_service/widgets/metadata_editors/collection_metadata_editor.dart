import 'dart:convert';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../../basic_page_service/widgets/page_manager.dart';

class CollectionMetadataEditor extends ConsumerStatefulWidget {
  factory CollectionMetadataEditor({
    required int? id,
    required void Function(StoreEntity collection) onSubmit,
    required void Function() onCancel,
    Key? key,
  }) {
    return CollectionMetadataEditor._(
      id: id,
      onSubmit: onSubmit,
      onCancel: onCancel,
      isDialog: false,
      key: key,
    );
  }
  factory CollectionMetadataEditor.dialog({
    required int id,
    required void Function(StoreEntity collection) onSubmit,
    required void Function() onCancel,
    Key? key,
  }) {
    return CollectionMetadataEditor._(
      id: id,
      onSubmit: onSubmit,
      onCancel: onCancel,
      isDialog: true,
      key: key,
    );
  }
  const CollectionMetadataEditor._({
    required this.id,
    required this.isDialog,
    required this.onSubmit,
    required this.onCancel,
    super.key,
  });

  final int? id;

  final void Function(StoreEntity collection) onSubmit;
  final void Function() onCancel;
  final bool isDialog;

  @override
  ConsumerState<CollectionMetadataEditor> createState() =>
      _CollectionMetadataEditorState();

  static Future<StoreEntity?> openSheet(
    BuildContext context,
    WidgetRef ref, {
    required StoreEntity collection,
  }) async {
    return showShadSheet<StoreEntity>(
      context: context,
      builder: (BuildContext context) => CollectionMetadataEditor.dialog(
        id: collection.id!,
        onSubmit: (collection) {
          PageManager.of(context).pop(collection);
        },
        onCancel: () => PageManager.of(context).pop(),
      ),
    );
  }
}

class _CollectionMetadataEditorState
    extends ConsumerState<CollectionMetadataEditor> {
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
      child: GetEntity(
        id: widget.id,
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
          return GetEntities(
            isHidden: null,
            isDeleted: null,
            errorBuilder: errorBuilder,
            loadingBuilder: () => loading('GetAllCollection'),
            builder: (allCollections) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ShadSheet(
                  draggable: true,
                  title: Text(
                    'Edit Collection "${collection.data.label!.capitalizeFirstLetter()}"',
                  ),
                  description: const Text(
                    'Change the label and add/update description here',
                  ),
                  actions: [
                    ShadButton(
                      child: const Text('Save changes'),
                      onPressed: () async {
                        if (formKey.currentState!.saveAndValidate()) {
                          formValue = formKey.currentState!.value;
                          final label = formValue['label'] as String;
                          final desc = formValue['description'] as String?;
                          final updated = await collection.updateWith(
                            label: () => label,
                            description: () => desc == null
                                ? null
                                : desc.isEmpty
                                    ? null
                                    : desc,
                          );
                          if (updated == null) {
                            throw Exception('update failed');
                          }

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
                          initialValue: collection.data.label,
                          placeholder: const Text('Enter collection name'),
                          validator: (value) => validateName(
                            newLabel: value,
                            existingLabel: collection.data.label,
                            collections: allCollections,
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
                          initialValue: collection.data.description,
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
    required List<StoreEntity> collections,
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
          .map((e) => e.data.label!.trim().toLowerCase())
          .contains(newLabel0.toLowerCase())) {
        return '$newLabel0 already exists';
      }
    }
    return null;
  }
}
