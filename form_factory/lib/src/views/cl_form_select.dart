import 'dart:async';

import 'package:flutter/material.dart';

import '../models/cl_form_field_descriptors.dart';
import '../models/cl_form_field_state.dart';
import '../style/cl_form_design.dart';
import '../models/list_extensions.dart';

class CLFormSelect extends StatelessWidget {
  const CLFormSelect({
    required this.descriptors,
    required this.state,
    required this.onRefresh,
    super.key,
  });
  final CLFormSelectDescriptors descriptors;

  final CLFormSelectState state;

  final void Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return FormField<List<Object>>(
        validator: (value) {
          if (value!.isEmpty) {
            return "Atleast one value should be provided";
          }

          state.selectedEntities.clear();
          state.selectedEntities.addAll(value);
          return null;
        },
        initialValue: state.selectedEntities,
        builder: (fieldState) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: double.infinity,
              height: kMinInteractiveDimension * 3,
              child: InputDecorator(
                decoration: FormDesign.inputDecoration(descriptors.label),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    controller: state.scrollController,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Wrap(
                        key: state.wrapKey,
                        spacing: 1,
                        runSpacing: 1,
                        children: [
                          ...fieldState.value!.map(
                            (e) => Theme(
                              data: Theme.of(context).copyWith(
                                chipTheme: const ChipThemeData(
                                  side: BorderSide.none,
                                ),
                                canvasColor: Colors.transparent,
                              ),
                              child: Chip(
                                label: Text(descriptors.labelBuilder(e)),
                                onDeleted: () {
                                  fieldState.value!.remove(e);
                                  onRefresh();
                                },
                              ),
                            ),
                          ),
                          SearchAnchor(
                            searchController: state.searchController,
                            isFullScreen: false,
                            viewBackgroundColor:
                                Theme.of(context).colorScheme.surface,
                            suggestionsBuilder: (context, controller) {
                              return suggestionsBuilder(context,
                                  suggestions: descriptors.suggestionsAvailable
                                      .excludeByLabel(
                                        fieldState.value!,
                                        descriptors.labelBuilder,
                                      )
                                      .toList(),
                                  controller: controller,
                                  labelBuilder: descriptors.labelBuilder,
                                  fieldState: fieldState);
                            },
                            builder: (context, controller) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  canvasColor: Colors.transparent,
                                ),
                                child: ActionChip(
                                  avatar: const Icon(Icons.add),
                                  label: Text(
                                    fieldState.value!.isEmpty ? 'Add' : 'Add',
                                  ),
                                  onPressed: controller.openView,
                                  shape: const ContinuousRectangleBorder(
                                    side: BorderSide(),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(16),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
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
    required FormFieldState<List<Object>> fieldState,
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
    FormFieldState<List<Object>> fieldState,
    Object item,
    void Function() onRefresh,
  ) async {
    final entityUpdated = await descriptors.onSelectSuggestion(item);
    if (entityUpdated == null) return;
    state.searchController.text = '';
    fieldState.didChange([...fieldState.value!, entityUpdated]);
    onRefresh();
    Future.delayed(const Duration(milliseconds: 200), state.scrollToEnd);
  }

  Future<void> _onCreateByLabel(
    FormFieldState<List<Object>> fieldState,
    String label,
    void Function() onRefresh,
  ) async {
    final entityUpdated = await descriptors.onCreateByLabel(label);
    if (entityUpdated == null) return;
    state.searchController.text = '';
    fieldState.didChange([...fieldState.value!, entityUpdated]);
    onRefresh();
    Future.delayed(const Duration(milliseconds: 200), state.scrollToEnd);
  }
}
