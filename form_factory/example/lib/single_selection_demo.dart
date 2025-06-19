// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

@immutable
class DemoItem {
  const DemoItem({required this.label});
  final String label;

  @override
  String toString() => 'DemoItem(label: $label)';

  DemoItem copyWith({String? label}) {
    return DemoItem(label: label ?? this.label);
  }

  @override
  bool operator ==(covariant DemoItem other) {
    if (identical(this, other)) return true;

    return other.label == label;
  }

  @override
  int get hashCode => label.hashCode;
}

List<DemoItem> items = [
  DemoItem(label: 'item 1'),
  DemoItem(label: 'item 2'),
  DemoItem(label: 'item 3'),
  DemoItem(label: 'item 4'),
];

class SingleSelectionDemo extends StatefulWidget {
  const SingleSelectionDemo({super.key, required this.title});

  final String title;

  @override
  State<SingleSelectionDemo> createState() => SingleSelectionDemoState();
}

class SingleSelectionDemoState extends State<SingleSelectionDemo> {
  DemoItem? selected /* = items[2] */;
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return CLWizardFormField(
      descriptor: CLFormSelectSingleDescriptors(
        title: 'Select Single Demo',
        label: 'Select an Item',
        labelBuilder: (e) => (e as DemoItem).label,
        descriptionBuilder: (e) => (e as DemoItem).label,
        suggestionsAvailable: items,
        initialValues: selected,
        onSelectSuggestion: (item) async => item,
        onCreateByLabel: (label) {
          return DemoItem(label: label);
        },
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
          selected =
              (result as CLFormSelectSingleResult).selectedEntitry as DemoItem?;
        });
      },
      backgroundColor: theme.colorScheme.background,
      foregroundColor: theme.colorScheme.foreground,
      mutedForegroundColor: theme.colorScheme.mutedForeground,
      footerText: selected?.toString(),
      rightControl: CLMenuItem(title: 'Next', icon: Icons.arrow_right),
    );
  }
}
