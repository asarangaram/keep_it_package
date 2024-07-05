import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

enum EditorFinalActions {
  save,
  saveAsNew,
  revertToOriginal,
  discard;

  String get label => switch (this) {
        save => 'Save',
        saveAsNew => 'Save Copy',
        revertToOriginal => 'Reset to Original',
        discard => 'Discard',
      };
}

class EditorFinalizer extends StatelessWidget {
  const EditorFinalizer({
    required this.onSave,
    required this.onDiscard,
    this.child,
    this.allowCopy = true,
    super.key,
  });
  final Future<void> Function({required bool overwrite}) onSave;
  final Future<void> Function({required bool done}) onDiscard;
  final Widget? child;
  final bool allowCopy;
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<EditorFinalActions>(
      child: child ??
          CLIcon.small(
            MdiIcons.check,
            color: CLTheme.of(context).colors.iconColor,
          ),
      onSelected: (EditorFinalActions value) async {
        switch (value) {
          case EditorFinalActions.save:
            await onSave(overwrite: true);
          case EditorFinalActions.saveAsNew:
            await onSave(overwrite: false);
          case EditorFinalActions.revertToOriginal:
            await onDiscard(done: false);
          case EditorFinalActions.discard:
            await onDiscard(done: true);
        }
      },
      itemBuilder: (BuildContext context) {
        return EditorFinalActions.values
            .where((e) => allowCopy || e != EditorFinalActions.saveAsNew)
            .map(
              (e) => PopupMenuItem<EditorFinalActions>(
                value: e,
                child: Text(e.label),
              ),
            )
            .toList();
      },
    );
  }
}
