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
  final CLMedia? collection;
  final void Function(CLMedia) onDone;
  final bool Function(CLMedia collection)? isValidSuggestion;

  @override
  Widget build(BuildContext context) {
    return GetCollectionMultiple(
      errorBuilder: (_, __) {
        throw UnimplementedError('errorBuilder');
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetCollectionMultiple',
      ),
      query: DBQueries.mediaAll,
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
            labelBuilder: (e) => (e as CLMedia).label!,
            descriptionBuilder: (e) => (e as CLMedia).description,
            suggestionsAvailable: [
              if (isValidSuggestion != null)
                ...collections.entries.where((e) => isValidSuggestion!(e))
              else
                ...collections.entries,
            ],
            initialValues: collection,
            onSelectSuggestion: (item) async => item,
            onCreateByLabel: (label) async {
              final timeNow = DateTime.now();
              return CLMedia.collection(
                label: label,
                id: null,
                addedDate: timeNow,
                updatedDate: timeNow,
              );
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
                (result as CLFormSelectSingleResult).selectedEntitry as CLMedia;

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

  final CLMedia? collection;
  final void Function(CLMedia p1) onDone;

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
        labelBuilder: (e) => (e as CLMedia).label!,
        descriptionBuilder: (e) => (e as CLMedia).description,
        suggestionsAvailable: const [],
        initialValues: collection,
        onSelectSuggestion: (item) async => item,
        onCreateByLabel: (label) async {
          final timeNow = DateTime.now();
          return CLMedia.collection(
            id: null,
            label: label,
            addedDate: timeNow,
            updatedDate: timeNow,
          );
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
            (result as CLFormSelectSingleResult).selectedEntitry as CLMedia;

        onDone(collection);
      },
    );
  }
}
