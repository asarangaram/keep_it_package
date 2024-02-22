import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'cl_form_design.dart';
import 'cl_form_field_descriptors.dart';
import 'cl_form_field_result.dart';
import 'cl_form_field_state.dart';

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
                    ...(state.result as CLFormSelectResult)
                        .selectedEntities
                        .map(
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
                                state.remove(e);
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
                        return suggestionsBuilder(
                          context,
                          suggestions: descriptors.suggestionsAvailable
                              .excludeByLabel(
                                (state.result as CLFormSelectResult)
                                    .selectedEntities,
                                descriptors.labelBuilder,
                              )
                              .toList(),
                          controller: controller,
                          labelBuilder: descriptors.labelBuilder,
                        );
                      },
                      builder: (context, controller) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.transparent,
                          ),
                          child: ActionChip(
                            avatar: Icon(MdiIcons.plus),
                            label: Text(
                              (state.result as CLFormSelectResult)
                                      .selectedEntities
                                      .isEmpty
                                  ? 'Add'
                                  : 'Add',
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
  }

  FutureOr<Iterable<Widget>> suggestionsBuilder(
    BuildContext context, {
    required SearchController controller,
    required String Function(Object e) labelBuilder,
    String Function(Object e)? descriptionBuilder,
    List<Object>? suggestions,
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
              _onSelect(state, e, onRefresh);
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
                  _onCreateByLabel(state, controller.text, onRefresh);
                } else {
                  _onSelect(state, c, onRefresh);
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
    CLFormSelectState state,
    Object item,
    void Function() onRefresh,
  ) async {
    final entityUpdated = await descriptors.onSelectSuggestion(item);
    if (entityUpdated == null) return;
    state.searchController.text = '';
    state.insert(entityUpdated);
    onRefresh();
    Future.delayed(const Duration(milliseconds: 200), state.scrollToEnd);
  }

  Future<void> _onCreateByLabel(
    CLFormSelectState state,
    String label,
    void Function() onRefresh,
  ) async {
    final entityUpdated = await descriptors.onCreateByLabel(label);
    if (entityUpdated == null) return;
    state.searchController.text = '';
    state.insert(entityUpdated);
    onRefresh();
    Future.delayed(const Duration(milliseconds: 200), state.scrollToEnd);
  }
}
