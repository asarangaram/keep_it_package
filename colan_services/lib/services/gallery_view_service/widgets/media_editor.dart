import 'dart:convert';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../context_menu_service/widgets/pull_down_context_menu.dart';
import '../../media_view_service/preview/media_preview_service.dart';

class MediaMetadataEditor extends StatelessWidget {
  factory MediaMetadataEditor({
    required int mediaId,
    required void Function(CLMedia media) onSubmit,
    required void Function() onCancel,
    Key? key,
  }) {
    return MediaMetadataEditor._(
      mediaId: mediaId,
      onSubmit: onSubmit,
      onCancel: onCancel,
      isDialog: false,
      key: key,
    );
  }
  factory MediaMetadataEditor.dialog({
    required int mediaId,
    required void Function(CLMedia media) onSubmit,
    required void Function() onCancel,
    Key? key,
  }) {
    return MediaMetadataEditor._(
      mediaId: mediaId,
      onSubmit: onSubmit,
      onCancel: onCancel,
      isDialog: true,
      key: key,
    );
  }
  const MediaMetadataEditor._({
    required this.mediaId,
    required this.isDialog,
    required this.onSubmit,
    required this.onCancel,
    super.key,
  });

  final int mediaId;

  final void Function(CLMedia media) onSubmit;
  final void Function() onCancel;
  final bool isDialog;

  static Future<CLMedia?> openSheet(
    BuildContext context,
    WidgetRef ref, {
    required CLMedia media,
  }) async {
    return showShadSheet<CLMedia>(
      context: context,
      builder: (BuildContext context) => MediaMetadataEditor.dialog(
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
      child: GetMedia(
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
          return GetCollection(
            id: media.parentId,
            errorBuilder: errorBuilder,
            loadingBuilder: () => loading(context, 'GetCollectionMultiple'),
            builder: (collection) {
              return StatefulMediaEditor(
                media: media,
                onCancel: onCancel,
                onSubmit: onSubmit,
              );
            },
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

  final CLMedia media;

  final void Function(CLMedia media) onSubmit;
  final void Function() onCancel;

  @override
  State<StatefulMediaEditor> createState() => _StatefulMediaEditorState();
}

class _StatefulMediaEditorState extends State<StatefulMediaEditor> {
  final formKey = GlobalKey<ShadFormState>();
  Map<Object, dynamic> formValue = {};
  late final TextEditingController nameController;
  late final TextEditingController refController;

  @override
  void initState() {
    nameController = TextEditingController();
    refController = TextEditingController();
    nameController.text = widget.media.label;
    refController.text = widget.media.description ?? '';
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    nameController.dispose();
    refController.dispose();
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
        title: Text(
          'Edit Media "${widget.media.label.capitalizeFirstLetter()}"',
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
                final name = formValue['name'] as String;
                final ref = formValue['ref'] as String?;
                final updated = widget.media.updateContent(
                  name: () => name,
                  ref: () => ref == null
                      ? null
                      : ref.isEmpty
                          ? null
                          : ref,
                );
                widget.onSubmit(updated);
              }
            },
          ),
        ],
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: MediaThumbnail(media: widget.media),
            ),
            Flexible(
              child: ShadForm(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShadInputFormField(
                      controller: nameController,
                      id: 'name',
                      // prefix: const Icon(LucideIcons.tag),
                      label: const Text(' Media Name'),

                      placeholder: const Text('Enter media name'),
                      validator: (value) => validateName(
                        newLabel: value,
                        existingLabel: widget.media.label,
                      ),
                      showCursor: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(
                          RegExp(r'\n'),
                        ),
                      ],
                      suffix: ShadButton.ghost(
                        onPressed: nameController.clear,
                        child: const Icon(LucideIcons.delete),
                      ),
                    ),
                    ShadInputFormField(
                      id: 'ref',
                      // prefix: const Icon(LucideIcons.tag),
                      label: const Text(' Reference'),
                      controller: refController,
                      placeholder: const Text('Reference Link'),
                      validator: isValidUrl,
                      suffix: ShadButton.ghost(
                        onPressed: refController.clear,
                        child: const Icon(LucideIcons.delete),
                      ),
                    ),
                    if (kDebugMode) MapInfo(widget.media.toMapForDisplay()),
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
