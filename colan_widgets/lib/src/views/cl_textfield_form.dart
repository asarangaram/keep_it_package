import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../basics/cl_button.dart';
import '../basics/cl_text.dart';
import '../basics/cl_text_field.dart';

enum CLFormFieldTypes { textField, textFieldMultiLine }

class CLFormField {
  CLFormFieldTypes type;
  String? Function(String?) validator;
  String? label;
  String? hint;
  String initialValue;
  CLFormField({
    required this.type,
    required this.validator,
    this.label,
    this.hint,
    required this.initialValue,
  });
}

class CLTextFieldForm extends ConsumerStatefulWidget {
  final String buttonLabel;
  final List<CLFormField> clFormFields;
  final Function(List<String> values) onSubmit;

  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? disabledColor;
  final Color? errorColor;

  const CLTextFieldForm({
    super.key,
    required this.buttonLabel,
    required this.clFormFields,
    required this.onSubmit,
    this.foregroundColor,
    this.backgroundColor,
    this.disabledColor,
    this.errorColor,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CLTextFieldFormState();
}

class _CLTextFieldFormState extends ConsumerState<CLTextFieldForm> {
  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;
  String? errorMessage;

  @override
  void initState() {
    controllers = widget.clFormFields
        .map((e) => TextEditingController(text: e.initialValue))
        .toList();
    focusNodes = widget.clFormFields.map((e) => FocusNode()).toList();

    super.initState();
  }

  @override
  void dispose() {
    for (var element in controllers) {
      element.dispose();
    }
    for (var element in focusNodes) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobilePlatform = Platform.isAndroid || Platform.isIOS;

    final formKey = GlobalKey<FormState>();
    return Theme(
      data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        disabledBorder: CLTextField.buildOutlineInputBorder(context),
        enabledBorder: CLTextField.buildOutlineInputBorder(context),
        focusedBorder: CLTextField.buildOutlineInputBorder(context, width: 2),
        errorBorder: CLTextField.buildOutlineInputBorder(context),
        focusedErrorBorder:
            CLTextField.buildOutlineInputBorder(context, width: 2),
        errorStyle: CLTextField.buildTextStyle(context),
        floatingLabelStyle: CLTextField.buildTextStyle(context),
      )),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              for (var field in widget.clFormFields.asMap().entries)
                switch (field.value.type) {
                  CLFormFieldTypes.textField => CLTextField.form,
                  CLFormFieldTypes.textFieldMultiLine =>
                    CLTextField.multiLineForm
                }(
                  controllers[field.key],
                  validator: field.value.validator,
                  focusNode: focusNodes[field.key],
                  label: field.value.label,
                  hint: field.value.hint,
                ),
              if (errorMessage != null)
                CLText.small(errorMessage!, color: widget.errorColor),
              Center(
                child: CLButtonText.large(
                  widget.buttonLabel,
                  color: widget.foregroundColor,
                  disabledColor: widget.disabledColor,
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      errorMessage = widget
                          .onSubmit(controllers.map((e) => e.text).toList());
                      setState(() {});
                    }
                  },
                ),
              ),
              if (isMobilePlatform)
                Align(
                  alignment: Alignment.centerLeft,
                  child: CLButtonIcon.small(Icons.keyboard_hide,
                      color: widget.foregroundColor,
                      disabledColor: widget.disabledColor,
                      onTap: MediaQuery.of(context).viewInsets.bottom > 0
                          ? () {}
                          : null),
                )
            ]),
          ),
        ),
      ),
    );
  }
}
