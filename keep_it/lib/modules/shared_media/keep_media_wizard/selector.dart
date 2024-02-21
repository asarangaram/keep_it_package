import 'dart:async';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../aaa/models/cl_form_field_descriptors.dart';
import '../../../aaa/models/cl_form_field_result.dart';
import '../../../aaa/models/cl_form_field_state.dart';

extension ExtMaterial on Color {
  MaterialColor materialColor() {
    final red = this.red;
    final green = this.green;
    final blue = this.blue;
    final alpha = this.alpha;

    final shades = <int, Color>{
      50: Color.fromARGB(alpha, red, green, blue),
      100: Color.fromARGB(alpha, red, green, blue),
      200: Color.fromARGB(alpha, red, green, blue),
      300: Color.fromARGB(alpha, red, green, blue),
      400: Color.fromARGB(alpha, red, green, blue),
      500: Color.fromARGB(alpha, red, green, blue),
      600: Color.fromARGB(alpha, red, green, blue),
      700: Color.fromARGB(alpha, red, green, blue),
      800: Color.fromARGB(alpha, red, green, blue),
      900: Color.fromARGB(alpha, red, green, blue),
    };

    return MaterialColor(value, shades);
  }
}

class FormDesign {
  static InputDecoration inputDecoration(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          gapPadding: 0,
        ),
      );
}

class Selector extends StatefulWidget {
  const Selector({
    required this.descriptors,
    required this.onSubmit,
    super.key,
  });
  final CLFormFieldDescriptors descriptors;
  final void Function(List<Object> selectedTags) onSubmit;
  @override
  State<Selector> createState() => SelectorState();
}

class SelectorState extends State<Selector> {
  late CLFormFieldState state;
  final formKey = GlobalKey<FormState>();
  String? errorMessage = 'This is Error';

  @override
  void initState() {
    state = CLFormSelectState(
      scrollController: ScrollController(),
      searchController: SearchController(),
      wrapKey: GlobalKey(),
      result: CLFormSelectResult(
        (widget.descriptors as CLFormSelectDescriptors).initialValues,
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobilePlatform = Platform.isAndroid || Platform.isIOS;
    return Form(
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CLText.large(
                widget.descriptors.title,
                textAlign: TextAlign.start,
              ),
              CLFormSelect(
                descriptors: widget.descriptors as CLFormSelectDescriptors,
                state: state as CLFormSelectState,
                onRefresh: () {
                  setState(() {});
                },
              ),
              if (errorMessage != null)
                Center(
                  child: CLText.standard(
                    errorMessage!,
                    textAlign: TextAlign.start,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceVariant, // Change this color to the desired color
                  ),
                  onPressed: () {},
                  child: CLButtonText.large(
                    'Submit',
                    onTap: () {
                      print(
                        (state.result as CLFormSelectResult).selectedEntities,
                      );
                      if (formKey.currentState?.validate() ?? false) {}
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: null,
                  child: CLButtonIcon.small(
                    Icons.keyboard_hide,
                    onTap: (isMobilePlatform && FocusScope.of(context).hasFocus)
                        ? () => FocusScope.of(context).unfocus()
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

/*
onDelete: (CLFormSelectState state, Object e) {
        
      },
*/