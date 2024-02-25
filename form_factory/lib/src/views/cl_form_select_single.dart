import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart' as cl;
import 'package:flutter/material.dart';

import '../models/cl_form_field_descriptors.dart';
import '../models/cl_form_field_state.dart';

class CLFormSelectSingle extends StatelessWidget {
  const CLFormSelectSingle({
    required this.descriptors,
    required this.state,
    required this.onRefresh,
    this.actionBuilder,
    super.key,
  });
  final CLFormSelectSingleDescriptors descriptors;
  final CLFormSelectSingleState state;
  final void Function() onRefresh;
  final Widget Function(BuildContext context)? actionBuilder;

  @override
  Widget build(BuildContext context) {
    return FormField<Object?>(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null) {
            return "can't be empty";
          }
          return null;
        },
        initialValue: descriptors.initialValues,
        builder: (fieldState) {
          return SizedBox(
            width: double.infinity,
            height: kMinInteractiveDimension * 3,
            child: InputDecorator(
              decoration: InputDecoration(
                enabled: true,
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(20, 8, 4, 8),
                labelText: descriptors.label,
                labelStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
                enabledBorder: fieldState.hasError
                    ? OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        gapPadding: 8,
                      )
                    : OutlineInputBorder(
                        borderSide: const BorderSide(width: 1),
                        borderRadius: BorderRadius.circular(16),
                        gapPadding: 8,
                      ),
                suffixIcon: fieldState.value != null
                    ? null
                    : actionBuilder?.call(
                        context,
                      ),
              ),
              child: Align(
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
                        child: fieldState.value == null
                            ? const Text("Nothing Selected")
                            : Text(descriptors.labelBuilder(fieldState.value!)),
                      ),
                    );
                  },
                ),
              ),
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
    if (controller.text.isEmpty) {
      filterredSuggestion = suggestions;
    } else {
      filterredSuggestion = suggestions
          ?.where(
            (element) => labelBuilder(element).contains(controller.text),
          )
          .toList();
    }

    final list = filterredSuggestion?.map<Widget>((e) {
          final description = descriptionBuilder?.call(e);
          return ListTile(
            title: Text(labelBuilder(e)),
            subtitle: description == null ? null : Text(description),
            onTap: () {
              controller.closeView(controller.text);
              _onSelect(fieldState, e, onRefresh);
            },
          );
        }).toList() ??
        [];
    if (controller.text.isNotEmpty) {
      final c = suggestions?.getByLabel(controller.text, labelBuilder);

      if (c == null) {
        list.add(
          ListTile(
            title: Text('Create "${controller.text}"'),
            onTap: () {
              if (controller.text.isNotEmpty) {
                controller.closeView(controller.text);

                final c = suggestions?.getByLabel(
                  controller.text,
                  labelBuilder,
                );
                if (c == null) {
                  _onCreateByLabel(fieldState, controller.text, onRefresh);
                } else {
                  _onSelect(fieldState, c, onRefresh);
                }
              }
            },
          ),
        );
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
    state.searchController.text = '';
    fieldState.didChange(entityUpdated);
    onRefresh();
    Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> _onCreateByLabel(
    FormFieldState<Object?> fieldState,
    String label,
    void Function() onRefresh,
  ) async {
    final entityUpdated = await descriptors.onCreateByLabel(label);
    if (entityUpdated == null) return;
    state.searchController.text = '';
    fieldState.didChange(entityUpdated);
    onRefresh();
    Future.delayed(const Duration(milliseconds: 200));
  }
}
