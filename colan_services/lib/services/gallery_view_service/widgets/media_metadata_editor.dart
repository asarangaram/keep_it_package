import 'dart:convert';

import 'package:cl_entity_viewers/cl_entity_viewers.dart' show MediaThumbnail;
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import 'context_menu_pulldown.dart';

class MediaMetadataEditor extends StatelessWidget {
  factory MediaMetadataEditor({
    required String storeIdentity,
    required int mediaId,
    required void Function(StoreEntity media) onSubmit,
    required void Function() onCancel,
    Key? key,
  }) {
    return MediaMetadataEditor._(
      storeIdentity: storeIdentity,
      mediaId: mediaId,
      onSubmit: onSubmit,
      onCancel: onCancel,
      isDialog: false,
      key: key,
    );
  }
  factory MediaMetadataEditor.dialog({
    required String storeIdentity,
    required int mediaId,
    required void Function(StoreEntity media) onSubmit,
    required void Function() onCancel,
    Key? key,
  }) {
    return MediaMetadataEditor._(
      storeIdentity: storeIdentity,
      mediaId: mediaId,
      onSubmit: onSubmit,
      onCancel: onCancel,
      isDialog: true,
      key: key,
    );
  }
  const MediaMetadataEditor._({
    required this.storeIdentity,
    required this.mediaId,
    required this.isDialog,
    required this.onSubmit,
    required this.onCancel,
    super.key,
  });

  final String storeIdentity;
  final int mediaId;

  final void Function(StoreEntity media) onSubmit;
  final void Function() onCancel;
  final bool isDialog;

  static Future<StoreEntity?> openSheet(
    BuildContext context,
    WidgetRef ref, {
    required StoreEntity media,
  }) async {
    return showShadSheet<StoreEntity>(
      context: context,
      builder: (BuildContext context) => MediaMetadataEditor.dialog(
        storeIdentity: media.store.store.identity,
        mediaId: media.id!,
        onSubmit: (media) {
          PageManager.of(context).pop(media);
        },
        onCancel: () => PageManager.of(context).pop(),
      ),
    );
  }

  Widget loading(BuildContext context, String debugMessage) => ShadSheet(
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: GetEntity(
        storeIdentity: storeIdentity,
        id: mediaId,
        errorBuilder: errorBuilder,
        loadingBuilder: () => loading(context, 'GetCollection'),
        builder: (media) {
          if (media == null) {
            try {
              throw Exception("Media can't be null");
            } catch (e, st) {
              return errorBuilder(e, st);
            }
          }
          return StatefulMediaEditor(
            media: media,
            onCancel: onCancel,
            onSubmit: onSubmit,
          );
        },
      ),
    );
  }
}

class StatefulMediaEditor extends StatefulWidget {
  const StatefulMediaEditor({
    required this.media,
    required this.onSubmit,
    required this.onCancel,
    super.key,
  });

  final StoreEntity media;

  final void Function(StoreEntity media) onSubmit;
  final void Function() onCancel;

  @override
  State<StatefulMediaEditor> createState() => _StatefulMediaEditorState();
}

class _StatefulMediaEditorState extends State<StatefulMediaEditor> {
  final formKey = GlobalKey<ShadFormState>();
  Map<Object, dynamic> formValue = {};
  late final TextEditingController labelController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    labelController = TextEditingController();
    descriptionController = TextEditingController();
    labelController.text = widget.media.data.label ?? '';
    descriptionController.text = widget.media.data.description ?? '';
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    labelController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ShadSheet(
        draggable: true,
        title: Row(
          spacing: 8,
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all()),
              width: 64,
              height: 64,
              child: MediaThumbnail(
                parentIdentifier: 'Metadata Editor', // FIXME
                media: widget.media,
              ),
            ),
            Text(
              widget.media.data.label?.capitalizeFirstLetter() ??
                  'Media #${widget.media.id}',
            ),
          ],
        ),
        actions: [
          ShadButton(
            child: const Text('Save changes'),
            onPressed: () async {
              if (formKey.currentState!.saveAndValidate()) {
                formValue = formKey.currentState!.value;
                final name = formValue['label'] as String;
                final description = formValue['description'] as String?;
                final updated = await (await widget.media.updateWith(
                  label: () => name,
                  description: () => description == null
                      ? null
                      : description.isEmpty
                          ? null
                          : description,
                ))
                    ?.dbSave();
                if (updated == null) {
                  throw Exception('updated should not be null!');
                }
                widget.onSubmit(updated);
              }
            },
          ),
        ],
        child: Row(
          children: [
            Flexible(
              child: ShadForm(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShadInputFormField(
                      controller: labelController,
                      id: 'label',
                      placeholder: Text('Media #${widget.media.id}'),
                      validator: (value) => validateName(
                        newLabel: value,
                        existingLabel: widget.media.data.label,
                      ),
                      showCursor: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(
                          RegExp(r'\n'),
                        ),
                      ],
                      padding: EdgeInsets.zero,
                      inputPadding: const EdgeInsets.all(4),
                    ),
                    ShadInputFormField(
                      id: 'description',
                      label: const Text(' About '),
                      controller: descriptionController,
                      placeholder: const Text('Write description'),
                      maxLines: 3,
                    ),
                    if (kDebugMode)
                      MapInfo(widget.media.data.toMapForDisplay()),
                    if (formValue.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24, left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FormValue',
                              style: theme.textTheme.p,
                            ),
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
          ],
        ),
      ),
    );
  }

  String? isValidUrl(String? url) {
    try {
      final newLabel0 = url?.trim();

      if (newLabel0 == null) {
        return null;
      } else {
        if (newLabel0.isEmpty) {
          return null;
        }
        final uri = Uri.parse(newLabel0);
        return uri.hasScheme && uri.hasAuthority
            ? null
            : ' Scheme and authority not provided ';
      }
    } catch (e) {
      return e.toString();
    }
  }

  String? validateName({
    required String? newLabel,
    required String? existingLabel,
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
    }
    return null;
  }
}
