import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import '../models/cl_form_field_descriptors.dart';
import '../models/cl_form_field_result.dart';
import '../models/cl_form_field_state.dart';

import 'cl_form_select_multiple.dart';
import 'cl_form_textfield.dart';

class CLForm extends StatefulWidget {
  const CLForm({
    required this.descriptors,
    required this.onSubmit,
    required this.onCancel,
    this.explicitScrollDownOption = true,
    super.key,
  });
  final Map<String, CLFormFieldDescriptors> descriptors;
  final void Function(Map<String, CLFormFieldResult> results) onSubmit;
  final void Function()? onCancel;
  final bool explicitScrollDownOption;
  @override
  State<CLForm> createState() => CLFormState();
}

class CLFormState extends State<CLForm> {
  late ScrollController listViewController;
  late Map<String, CLFormFieldState> state;
  final formKey = GlobalKey<FormState>();
  String? errorMessage;

  @override
  void initState() {
    listViewController = ScrollController();
    state = widget.descriptors.map(
      (key, desc) => MapEntry(
        key,
        switch (desc.runtimeType) {
          const (CLFormTextFieldDescriptor) => CLFormTextFieldState(
              controller: TextEditingController(
                text: (desc as CLFormTextFieldDescriptor).initialValue,
              ),
            ),
          const (CLFormSelectMultipleDescriptors) => CLFormSelectMultipleState(
              selectedEntities: List.from(
                  (desc as CLFormSelectMultipleDescriptors).initialValues),
              scrollController: ScrollController(),
              searchController: SearchController(),
              wrapKey: GlobalKey(),
            ),
          _ => throw Exception('Unsupported')
        },
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    listViewController.dispose();
    for (final item in state.entries) {
      item.value.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobilePlatform = Platform.isAndroid || Platform.isIOS;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Form(
        key: formKey,
        child: ListView(
          shrinkWrap: true,
          controller: listViewController,
          physics: const ClampingScrollPhysics(),
          children: [
            if (widget.explicitScrollDownOption)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(clIcons.down),
                  onPressed: () {
                    if (isMobilePlatform && FocusScope.of(context).hasFocus) {
                      FocusScope.of(context).unfocus();
                    }
                    listViewController.animateTo(
                      listViewController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            for (final entry in widget.descriptors.entries) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  entry.value.title,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: switch (entry.value.runtimeType) {
                  const (CLFormSelectMultipleDescriptors) =>
                    CLFormSelectMultiple(
                      descriptors:
                          entry.value as CLFormSelectMultipleDescriptors,
                      state: state[entry.key]! as CLFormSelectMultipleState,
                      onRefresh: () {
                        setState(() {});
                      },
                    ),
                  const (CLFormTextFieldDescriptor) => CLFormTextField(
                      descriptors: entry.value as CLFormTextFieldDescriptor,
                      state: state[entry.key]! as CLFormTextFieldState,
                      onRefresh: () {
                        setState(() {});
                      },
                    ),
                  _ => const SizedBox.shrink()
                },
              ),
            ],
            Center(
              child: Text(
                errorMessage ?? ' ',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (isMobilePlatform && FocusScope.of(context).hasFocus) {
                    FocusScope.of(context).unfocus();
                  }
                  if (formKey.currentState?.validate() ?? false) {
                    final result =
                        state.map((key, value) => MapEntry(key, value.result));
                    widget.onSubmit(result);
                  }
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(clIcons.hideKeyboard),
                      onPressed:
                          (isMobilePlatform && FocusScope.of(context).hasFocus)
                              ? () => FocusScope.of(context).unfocus()
                              : null,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: widget.onCancel == null
                        ? Container()
                        : TextButton(
                            onPressed: () {
                              widget.onCancel!();
                            },
                            child: const Text("Cancel")),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
