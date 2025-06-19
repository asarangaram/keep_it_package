// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TextFieldDemo extends StatefulWidget {
  const TextFieldDemo({super.key, required this.title});

  final String title;

  @override
  State<TextFieldDemo> createState() => TextFieldDemoState();
}

class TextFieldDemoState extends State<TextFieldDemo> {
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return CLWizardFormField(
      descriptor: CLFormTextFieldDescriptor(
        title: 'Select Single Demo',
        label: 'Select an Item',
        initialValue: "",
        maxLines: 4,
        onValidate: (value) {
          if (value == null) {
            return "can't be empty";
          }
          /* if ((value as Collection).label.length > 20) {
                    return "length can't exceed 20 characters";
                  } */
          return null;
        },
      ),
      onSubmit: (CLFormFieldResult result) async {
        setState(() {
          final text = (result as CLFormTextFieldResult).value as String?;
          print(text);
        });
      },
      backgroundColor: theme.colorScheme.background,
      foregroundColor: theme.colorScheme.foreground,
      mutedForegroundColor: theme.colorScheme.mutedForeground,

      rightControl: CLMenuItem(title: 'Next', icon: Icons.arrow_right),
    );
  }
}
