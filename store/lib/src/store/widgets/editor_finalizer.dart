import 'package:flutter/material.dart';

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
    super.key,
  });
  final Future<void> Function({required bool overwrite}) onSave;
  final Future<void> Function({required bool done}) onDiscard;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<EditorFinalActions>(
      child: child,
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
