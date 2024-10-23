import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';

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
    return GetCollectionMultiple(
      errorBuilder: null,
      loadingBuilder: null,
      excludeEmpty: false,
      builder: (collections) {
        return CLWizardFormField(
          actionMenu: (context, onTap) => CLMenuItem(
            icon: clIcons.next,
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
            onCreateByLabel: (label) async => Collection.byLabel(label),
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
            final collection = (result as CLFormSelectSingleResult)
                .selectedEntitry as Collection;

            onDone(collection);
          },
        );
      },
    );
  }
}
