import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';
import 'package:keep_it_state/keep_it_state.dart';

import 'package:store/store.dart';

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
    return GetAllVisibleCollection(
      errorBuilder: (_, __) {
        throw UnimplementedError('errorBuilder');
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetAllVisibleCollection',
      ),
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
            labelBuilder: (e) => (e as StoreEntity).entity.label!,
            descriptionBuilder: (e) => (e as StoreEntity).entity.description,
            suggestionsAvailable: [
              if (isValidSuggestion != null)
                ...collections.where((e) => isValidSuggestion!(e))
              else
                ...collections,
            ],
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
            final collection = (result as CLFormSelectSingleResult)
                .selectedEntitry as StoreEntity;

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

  final StoreEntity? collection;
  final void Function(StoreEntity p1) onDone;

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
        labelBuilder: (e) => (e as StoreEntity).entity.label!,
        descriptionBuilder: (e) => (e as StoreEntity).entity.description,
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
