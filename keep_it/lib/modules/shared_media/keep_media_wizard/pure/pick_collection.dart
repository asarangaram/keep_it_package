import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

class PickCollection extends StatelessWidget {
  const PickCollection({
    required this.collection,
    required this.onDone,
    super.key,
  });
  final Collection? collection;
  final void Function(Collection) onDone;

  @override
  Widget build(BuildContext context) {
    return LoadCollections(
      buildOnData: (collections) {
        return CLWizardFormField(
          actionMenu: (context, onTap) => CLMenuItem(
            icon: MdiIcons.arrowRight,
            title: 'Next',
            onTap: onTap,
          ),
          descriptor: CLFormSelectSingleDescriptors(
            title: 'Collection',
            label: 'Select Collection',
            labelBuilder: (e) => (e as Collection).label,
            descriptionBuilder: (e) => (e as Collection).description,
            suggestionsAvailable: [
              ...collections.entries,
            ],
            initialValues: collection,
            onSelectSuggestion: (item) async => item,
            onCreateByLabel: (label) async => Collection(label: label),
          ),
          onSubmit: (CLFormFieldResult result) async {
            final collection = (result as CLFormSelectSingleResult)
                .selectedEntitry as Collection;

            onDone(collection);
          },
        );
      },
    );
  }
}
