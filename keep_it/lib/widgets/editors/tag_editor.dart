import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:form_factory/form_factory.dart';
import 'package:store/store.dart';

class TagEditor extends StatelessWidget {
  factory TagEditor({
    required Tag? tag,
    required void Function(Tag tag) onSubmit,
    required void Function() onCancel,
    Key? key,
  }) {
    return TagEditor._(
      onSubmit: onSubmit,
      onCancel: onCancel,
      tag: tag,
      key: key,
      isDialog: false,
    );
  }
  factory TagEditor.dialog({
    required Tag? tag,
    required void Function(Tag tag) onSubmit,
    required void Function() onCancel,
    Key? key,
  }) {
    return TagEditor._(
      tag: tag,
      onSubmit: onSubmit,
      onCancel: onCancel,
      key: key,
      isDialog: true,
    );
  }
  const TagEditor._({
    required this.onSubmit,
    required this.onCancel,
    required this.isDialog,
    this.tag,
    super.key,
  });

  final Tag? tag;
  final void Function(Tag tag) onSubmit;
  final void Function()? onCancel;
  final bool isDialog;

  @override
  Widget build(BuildContext context) {
    return CLDialogWrapper(
      onCancel: isDialog ? onCancel : null,
      child: LoadTags(
        buildOnData: (existingTags) {
          return CLForm(
            explicitScrollDownOption: !isDialog,
            descriptors: {
              'label': CLFormTextFieldDescriptor(
                title: 'Name',
                label: 'Collection Name',
                initialValue: tag?.label ?? '',
                validator: (val) => validateName(val, existingTags),
                hint: 'Collection Name',
              ),
              'description': CLFormTextFieldDescriptor(
                title: 'About',
                label: 'Describe about this collection',
                initialValue: tag?.description ?? '',
                validator: (_) => null,
                hint: 'Collection Name',
                maxLines: 4,
              ),
            },
            onSubmit: (result) async {
              final label = (result['label']! as CLFormTextFieldResult).value;
              final desc =
                  (result['description']! as CLFormTextFieldResult).value;
              final updated = tag?.copyWith(
                    label: label,
                    description: desc.isEmpty ? null : desc,
                  ) ??
                  Tag(
                    label: label,
                    description: desc.isEmpty ? null : desc,
                  );
              onSubmit.call(updated);
            },
            onCancel: isDialog ? null : onCancel,
          );
        },
      ),
    );
  }

  String? validateName(String? name, Tags existingTags) {
    if (name?.isEmpty ?? true) {
      return "Name can't be empty";
    }
    /* if (name!.length > 16) {
      return 'Name should not exceed 15 letters';
    } */
    if (tag?.label == name) {
      // Nothing changed.
      return null;
    }
    if (existingTags.entries
        .map((e) => e.label.trim())
        .contains(name!.trim())) {
      return '$name already exists';
    }
    return null;
  }

  static Future<Tag?> popupDialog(
    BuildContext context, {
    required Tag tag,
  }) async =>
      showDialog<Tag>(
        context: context,
        builder: (BuildContext context) => TagEditor.dialog(
          tag: tag,
          onSubmit: (Tag? entity) {
            Navigator.of(context).pop(entity);
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      );
}
