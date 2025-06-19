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
          state.selectedEntitry.clear();
          final res = descriptors.onValidate?.call(value);
          if (res != null) return res;
          if (value != null) {
            state.selectedEntitry.add(value);
          }
          return null;
        },
        initialValue: descriptors.initialValues,
        builder: (fieldState) {
          return SearchAndSelect(
            fieldState: fieldState,
            descriptors: descriptors,
            state: state,
            onRefresh: onRefresh,
          );
        });
  }
}

class SearchAndSelect extends StatefulWidget {
  const SearchAndSelect({
    super.key,
    required this.descriptors,
    required this.state,
    required this.onRefresh,
    required this.fieldState,
  });
  final FormFieldState<Object?> fieldState;
  final CLFormSelectSingleDescriptors descriptors;
  final CLFormSelectSingleState state;
  final void Function() onRefresh;

  @override
  State<SearchAndSelect> createState() => _SearchAndSelectState();
}

class _SearchAndSelectState extends State<SearchAndSelect> {
  @override
  Widget build(BuildContext context) {
    String? errorText;
    final currentSelection = widget.state.selectedEntitry.firstOrNull;
    if (currentSelection != null) {
      if (!widget.descriptors.isSuggestedEntry(currentSelection)) {
        //  errorText = widget.descriptors.errorWhenObjectNotFound;
      }
    }

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              scrim: Colors.black
                  .withValues(alpha: 0.5), // Your desired scrim color
            ),
      ),
      child: SearchAnchor(
        searchController: widget.state.searchController,
        isFullScreen: false,
        shrinkWrap: true,
        viewBackgroundColor: Colors.white,
        suggestionsBuilder: (context, controller) {
          return suggestionsBuilder(context,
              suggestions: widget.descriptors.suggestionsAvailable,
              controller: controller,
              labelBuilder: widget.descriptors.labelBuilder,
              fieldState: widget.fieldState);
        },
        builder: (context, controller) {
          return Align(
              alignment: Alignment.bottomCenter,
              child: TextField(
                decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedErrorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    errorText: errorText,
                    hintText: widget.descriptors.hintText,
                    hintStyle: TextStyle(color: Colors.grey)),
                controller: controller,
                onTap: controller.openView,
                onChanged: (_) => controller.openView(),
              ));
        },
      ),
    );
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
      fieldState.didChange(null);

      widget.onRefresh();
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
              _onSelect(e);
            },
          );
        }).toList() ??
        [];
    if (controllerText.isNotEmpty) {
      final c = suggestions?.getByLabel(controllerText, labelBuilder);

      if (c == null) {
        _onCreateByLabel(controllerText);

        /*  */
      }
    }
    if (list.isEmpty) {
      return [
        ListTile(
          title: Text(widget.descriptors.errorWhenObjectNotFound),
        )
      ];
    }
    return list;
  }

  Future<void> _onSelect(
    Object item,
  ) async {
    final entityUpdated = await widget.descriptors.onSelectSuggestion(item);
    if (entityUpdated == null) return;
    widget.state.searchController.text =
        widget.descriptors.labelBuilder(entityUpdated);

    widget.state.searchController.selection = TextSelection.collapsed(
        offset: widget.state.searchController.text.length);

    widget.fieldState.didChange(entityUpdated);
    widget.onRefresh();
  }

  Object _onCreateByLabel(
    String label,
  ) {
    final entityUpdated = widget.descriptors.onCreateByLabel(label);
    widget.fieldState.didChange(entityUpdated);
    widget.onRefresh();
    setState(() {});
    return entityUpdated;
  }
}




/// Historical info
/// 
/// 
/// If you want to add a entry in the suggestion to create
/// list.add(ListTile(
///      title: Text("create ${labelBuilder(e)}"),
///      onTap: () {
///        controller.closeView(controllerText);
///        _onSelect(fieldState, e, onRefresh);
///      },
///    ));
/// 
/// If padding is conflicting, 
/// return list
///         /* ..add(
///         ListTile(
///           title: SizedBox(
///             height: MediaQuery.of(context).viewInsets.bottom,
///           ),
///         ),
///       ) */
///         ;
/// 


