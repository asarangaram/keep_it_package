import 'dart:async';

import 'package:flutter/material.dart';

import '../models/cl_form_field_descriptors.dart';
import '../models/cl_form_field_state.dart';
import '../models/list_ext.dart';

class CLFormSelectSingle extends StatelessWidget {
  const CLFormSelectSingle({
    required this.descriptors,
    required this.state,
    required this.onRefresh,
    super.key,
  });
  final CLFormSelectSingleDescriptors descriptors;
  final CLFormSelectSingleState state;
  final void Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return FormField<Object?>(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          final res = descriptors.onValidate?.call(value);

          if (res != null) return res;

          state.selectedEntitry.clear();
          state.selectedEntitry.add(value);

          return null;
        },
        initialValue: descriptors.initialValues,
        builder: (fieldState) {
          return Align(
            alignment: Alignment.topLeft,
            child: SearchAnchor(
              searchController: state.searchController,
              isFullScreen: false,
              viewBackgroundColor: Theme.of(context).colorScheme.surface,
              suggestionsBuilder: (context, controller) {
                return suggestionsBuilder(context,
                    suggestions: descriptors.suggestionsAvailable,
                    controller: controller,
                    labelBuilder: descriptors.labelBuilder,
                    fieldState: fieldState);
              },
              builder: (context, controller) {
                return GestureDetector(
                  onTap: controller.openView,
                  child: SizedBox.expand(
                    child: Center(
                        child: TextField(
                      controller: controller,
                      onTap: () {
                        controller.openView();
                      },
                      onChanged: (_) {
                        controller.openView();
                      },
                    )),
                  ),
                );
              },
            ),
          );
        });
  }

  FutureOr<Iterable<Widget>> suggestionsBuilder(
    BuildContext context, {
    required SearchController controller,
    required String Function(Object e) labelBuilder,
    String Function(Object e)? descriptionBuilder,
    List<Object>? suggestions,
    required FormFieldState<Object?> fieldState,
  }) {
    final List<Object>? filterredSuggestion;
    final controllerText = controller.text.trim();
    if (controllerText.isEmpty) {
      filterredSuggestion = suggestions;
    } else {
      filterredSuggestion = suggestions
          ?.where(
            (element) => labelBuilder(element).contains(controllerText),
          )
          .toList();
    }

    final list = filterredSuggestion?.map<Widget>((e) {
          final description = descriptionBuilder?.call(e);
          return ListTile(
            title: Text(labelBuilder(e)),
            subtitle: description == null ? null : Text(description),
            onTap: () {
              controller.closeView(controllerText);
              _onSelect(fieldState, e, onRefresh);
            },
          );
        }).toList() ??
        [];
    if (controllerText.isNotEmpty) {
      final c = suggestions?.getByLabel(controllerText, labelBuilder);

      if (c == null) {
        final e = _onCreateByLabel(fieldState, controllerText, onRefresh);

        list.add(ListTile(
          title: Text("create ${labelBuilder(e)}"),
          onTap: () {
            controller.closeView(controllerText);
            _onSelect(fieldState, e, onRefresh);
          },
        ));
      }
    }
    return list
      ..add(
        ListTile(
          title: SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          ),
        ),
      );
  }

  Future<void> _onSelect(
    FormFieldState<Object?> fieldState,
    Object item,
    void Function() onRefresh,
  ) async {
    final entityUpdated = await descriptors.onSelectSuggestion(item);
    if (entityUpdated == null) return;
    state.searchController.text = descriptors.labelBuilder(entityUpdated);
    fieldState.didChange(entityUpdated);
    //onRefresh();
  }

  Object _onCreateByLabel(
    FormFieldState<Object?> fieldState,
    String label,
    void Function() onRefresh,
  ) {
    final entityUpdated = descriptors.onCreateByLabel(label);

    fieldState.didChange(entityUpdated);
    return entityUpdated;
  }
}
