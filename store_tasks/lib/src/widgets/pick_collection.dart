import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';

import 'package:store/store.dart';

//FIXME - implement error Builder for Wizard Pick Collection

class PickCollection extends StatelessWidget {
  const PickCollection({
    required this.collection,
    required this.onDone,
    super.key,
    this.isValidSuggestion,
  });
  final StoreEntity? collection;
  final void Function(StoreEntity) onDone;
  final bool Function(StoreEntity collection)? isValidSuggestion;

  @override
  Widget build(BuildContext context) {
    return GetActiveStore(
      errorBuilder: (_, __) {
        throw UnimplementedError('errorBuilder');
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetAllVisibleCollection',
      ),
      builder: (theStore) {
        return GetEntities(
          isCollection: true,
          isHidden: null,
          isDeleted: null,
          errorBuilder: (_, __) {
            throw UnimplementedError('errorBuilder');
          },
          loadingBuilder: () => CLLoader.widget(
            debugMessage: 'GetAllVisibleCollection',
          ),
          builder: (collections) {
            return CLWizardFormField(
              descriptor: CLFormSelectSingleDescriptors(
                title: 'Collection',
                label: 'Select Collection',
                labelBuilder: (e) => (e as StoreEntity).data.label!,
                descriptionBuilder: (e) => (e as StoreEntity).data.description,
                suggestionsAvailable: [
                  if (isValidSuggestion != null)
                    ...collections.entities
                        .where((e) => isValidSuggestion!(e as StoreEntity))
                  else
                    ...collections.entities,
                ],
                initialValues: collection,
                onSelectSuggestion: (item) async => item,
                onCreateByLabel: (label) async {
                  return theStore.createCollection(label: label);
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
                final collection = (result as CLFormSelectSingleResult)
                    .selectedEntitry as StoreEntity;

                onDone(collection);
              },
            );
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

  final StoreEntity? collection;
  final void Function(StoreEntity p1) onDone;

  @override
  Widget build(BuildContext context) {
    return CLWizardFormField(
      descriptor: CLFormSelectSingleDescriptors(
        title: 'Collection',
        label: 'Select Collection',
        labelBuilder: (e) => (e as StoreEntity).data.label!,
        descriptionBuilder: (e) => (e as StoreEntity).data.description,
        suggestionsAvailable: const [],
        initialValues: collection,
        onSelectSuggestion: (item) async => item,
        onCreateByLabel: (label) async {
          throw UnimplementedError('Need a store create function here ');
          /* return StoreEntity.collection(
                label: label,
              ); */
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
        final collection =
            (result as CLFormSelectSingleResult).selectedEntitry as StoreEntity;

        onDone(collection);
      },
    );
  }
}
