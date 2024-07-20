import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../store_service/widgets/w3_get_collection.dart';

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
    return GetCollectionMultiple(
      buildOnData: (collections) {
        return CLWizardFormField<Collection>(
          actionMenu: (context, onTap) => CLMenuItem(
            icon: MdiIcons.arrowRight,
            title: 'Next',
            onTap: onTap,
          ),
          descriptor: CLFormSelectSingleDescriptors(
            title: 'Collection',
            label: 'Select Collection',
            labelBuilder: (e) => e.label,
            descriptionBuilder: (e) => e.description,
            suggestionsAvailable: [
              ...collections,
            ],
            initialValues: collection,
            onSelectSuggestion: (item) async => item,
            onCreateByLabel: (label) async => Collection(label: label),
            onValidate: (value) {
              if (value == null) {
                return "can't be empty";
              }
              return Collection.validateName(
                newLabel: value.label,
                existingLabel: collection?.label,
                collections: collections,
              );
            },
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
