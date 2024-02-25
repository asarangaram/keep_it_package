import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class EditCollectionDescription extends StatelessWidget {
  const EditCollectionDescription({
    required this.collection,
    required this.onDone,
    super.key,
  });
  final Collection collection;
  final void Function(Collection collection) onDone;

  @override
  Widget build(BuildContext context) {
    return CLWizardFormField(
      actionMenu: (context, onTap) => CLMenuItem(
        icon: MdiIcons.arrowRight,
        title: 'Select Tags',
        onTap: onTap,
      ),
      descriptor: CLFormTextFieldDescriptor(
        title: 'Description',
        label: 'About "${collection.label}"',
        initialValue: collection.label,
        hint: 'What is the best thing,'
            ' you can say about this?',
        validator: (val) => null,
        maxLines: 4,
      ),
      onSubmit: (CLFormFieldResult result) async {
        final description = (result as CLFormTextFieldResult).value;

        onDone(collection.copyWith(description: description));
      },
    );
  }
}
