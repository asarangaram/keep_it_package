import 'dart:async';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_it/aaa/models/cl_form_textfield.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'cl_form_field_descriptors.dart';
import 'cl_form_field_result.dart';
import 'cl_form_field_state.dart';
import 'cl_form_select.dart';

class Selector extends StatefulWidget {
  const Selector({
    required this.descriptors,
    required this.onSubmit,
    super.key,
  });
  final Map<String, CLFormFieldDescriptors> descriptors;
  final void Function(Map<String, CLFormFieldResult> results) onSubmit;
  @override
  State<Selector> createState() => SelectorState();
}

class SelectorState extends State<Selector> {
  late Map<String, CLFormFieldState> state;
  final formKey = GlobalKey<FormState>();
  String? errorMessage = 'This is Error';

  @override
  void initState() {
    state = widget.descriptors.map(
      (key, desc) => MapEntry(
        key,
        switch (desc.runtimeType) {
          CLFormTextFieldDescriptor => CLFormTextFieldState(
              result: CLFormTextFieldResult(),
              controller: TextEditingController(
                text: (desc as CLFormTextFieldDescriptor).initialValue,
              ),
            ),
          CLFormSelectDescriptors => CLFormSelectState(
              scrollController: ScrollController(),
              searchController: SearchController(),
              wrapKey: GlobalKey(),
              result: CLFormSelectResult(
                (desc as CLFormSelectDescriptors).initialValues,
              ),
            ),
          _ => throw Exception('Unsupported')
        },
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    for (final item in state.entries) {
      item.value.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobilePlatform = Platform.isAndroid || Platform.isIOS;
    return SingleChildScrollView(
      child: Form(
        child: Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in widget.descriptors.entries) ...[
                  CLText.large(
                    entry.value.title,
                    textAlign: TextAlign.start,
                  ),
                  switch (entry.value.runtimeType) {
                    CLFormSelectDescriptors => CLFormSelect(
                        descriptors: entry.value as CLFormSelectDescriptors,
                        state: state[entry.key]! as CLFormSelectState,
                        onRefresh: () {
                          setState(() {});
                        },
                      ),
                    CLFormTextFieldDescriptor => CLFormTextField(
                        descriptors: entry.value as CLFormTextFieldDescriptor,
                        state: state[entry.key]! as CLFormTextFieldState,
                        onRefresh: () {
                          setState(() {});
                        },
                      ),
                    _ => const SizedBox.shrink()
                  },
                ],
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
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    onPressed: () {},
                    child: CLButtonText.large(
                      'Submit',
                      onTap: () {
                        final result = state
                            .map((key, value) => MapEntry(key, value.result));
                        for (final s in result.entries) {
                          print(
                            (s.value as CLFormSelectResult).selectedEntities,
                          );
                        }
                        if (formKey.currentState?.validate() ?? false) {}
                        if (context.canPop()) {
                          context.pop();
                        }
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
                      onTap:
                          (isMobilePlatform && FocusScope.of(context).hasFocus)
                              ? () => FocusScope.of(context).unfocus()
                              : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
