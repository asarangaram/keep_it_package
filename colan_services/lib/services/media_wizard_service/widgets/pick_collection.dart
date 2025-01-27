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
    this.isValidSuggestion,
  });
  final Collection? collection;
  final void Function(Collection) onDone;
  final bool Function(Collection collection)? isValidSuggestion;

  @override
  Widget build(BuildContext context) {
    return GetCollectionMultiple(
      errorBuilder: (_, __) {
        throw UnimplementedError('errorBuilder');
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetCollectionMultiple',
      ),
      query: DBQueries.collectionsVisible,
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
            labelBuilder: (e) =>
                '${(e as Collection).label} ${e.hasServerUID ? '*' : ''}',
            descriptionBuilder: (e) => (e as Collection).description,
            suggestionsAvailable: [
              if (isValidSuggestion != null)
                ...collections.entries.where((e) => isValidSuggestion!(e))
              else
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

class PickCollectionWizard extends StatelessWidget {
  const PickCollectionWizard({
    required this.collection,
    required this.onDone,
    super.key,
  });

  final Collection? collection;
  final void Function(Collection p1) onDone;

  @override
  Widget build(BuildContext context) {
    return CLWizardFormField(
      actionMenu: (context, onTap) => CLMenuItem(
        icon: clIcons.next,
        title: 'Next',
        onTap: onTap,
      ),
      descriptor: CLFormSelectSingleDescriptors(
        title: 'Collection',
        label: 'Select Collection',
        labelBuilder: (e) =>
            '${(e as Collection).label} ${e.hasServerUID ? '*' : ''}',
        descriptionBuilder: (e) => (e as Collection).description,
        suggestionsAvailable: const [],
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
        final collection =
            (result as CLFormSelectSingleResult).selectedEntitry as Collection;

        onDone(collection);
      },
    );
  }
}
