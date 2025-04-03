import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';
import 'package:keep_it_state/keep_it_state.dart';

import 'package:store/store.dart';

class EditCollectionDescription extends StatelessWidget {
  const EditCollectionDescription({
    required this.collection,
    required this.onDone,
    super.key,
  });
  final CLMedia collection;
  final void Function(CLMedia collection) onDone;

  @override
  Widget build(BuildContext context) {
    return CLWizardFormField(
      actionMenu: (context, onTap) => CLMenuItem(
        icon: clIcons.save,
        title: 'Save',
        onTap: onTap,
      ),
      descriptor: CLFormTextFieldDescriptor(
        title: 'Description',
        label: 'About "${collection.label}"',
        initialValue: collection.label!,
        hint: 'What is the best thing,'
            ' you can say about "${collection.label}"?',
        onValidate: (val) => null,
        maxLines: 4,
      ),
      onSubmit: (CLFormFieldResult result) async {
        final description = (result as CLFormTextFieldResult).value;

        onDone(collection.copyWith(description: () => description));
      },
    );
  }
}
