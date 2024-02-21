import 'dart:io';

import 'package:colan_widgets/src/services/forms/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../basics/cl_button.dart';
import '../../basics/cl_text.dart';
import '../../basics/cl_text_field.dart';
import 'cl_selector.dart';

class CLTextFieldForm extends ConsumerStatefulWidget {
  const CLTextFieldForm({
    required this.buttonLabel,
    required this.clFormFields,
    required this.onSubmit,
    super.key,
    this.foregroundColor,
    this.backgroundColor,
    this.disabledColor,
    this.errorColor,
  });
  final String buttonLabel;
  final List<CLFormField> clFormFields;
  final String? Function(List<String> values) onSubmit;

  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? disabledColor;
  final Color? errorColor;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CLTextFieldFormState();
}

class _CLTextFieldFormState extends ConsumerState<CLTextFieldForm> {
  late final List<Object> controllers;
  late final List<FocusNode?> focusNodes;
  String? errorMessage;

  @override
  void initState() {
    controllers = widget.clFormFields.map((e) {
      return switch (e.runtimeType) {
        (final type) when type == CLFromFieldTypeText =>
          TextEditingController(text: (e as CLFromFieldTypeText).initialValue),
        (final type) when type == CLFromFieldTypeSelector => SearchController(),
        _ => TextEditingController()
      };
    }).toList();
    focusNodes = widget.clFormFields.map((e) {
      return switch (e.runtimeType) {
        (final type) when type == CLFromFieldTypeText => FocusNode(),
        _ => null
      };
    }).toList();

    widget.clFormFields.map((e) => FocusNode()).toList();

    super.initState();
  }

  @override
  void dispose() {
    for (final element in controllers) {
      if (element.runtimeType == TextEditingController) {
        (element as TextEditingController).dispose();
      } else if (element.runtimeType == SearchController) {
        (element as SearchController).dispose();
      }
    }
    for (final element in focusNodes) {
      element?.dispose();
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
        ),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final field in widget.clFormFields.asMap().entries)
                  switch (field.value.type) {
                    CLFormFieldTypes.textField => CLTextField.form(
                        controllers[field.key] as TextEditingController,
                        validator:
                            (field.value as CLFromFieldTypeText).validator,
                        focusNode: focusNodes[field.key],
                        label: (field.value as CLFromFieldTypeText).label,
                        hint: (field.value as CLFromFieldTypeText).hint,
                      ),
                    CLFormFieldTypes.textFieldMultiLine =>
                      CLTextField.multiLineForm(
                        controllers[field.key] as TextEditingController,
                        validator:
                            (field.value as CLFromFieldTypeText).validator,
                        focusNode: focusNodes[field.key],
                        label: (field.value as CLFromFieldTypeText).label,
                        hint: (field.value as CLFromFieldTypeText).hint,
                      ),
                    CLFormFieldTypes.selector => CLSelector(
                        controller: controllers[field.key] as SearchController,
                        selector: field.value as CLFromFieldTypeSelector,
                      )
                  },
                if (errorMessage != null)
                  CLText.small(errorMessage!, color: widget.errorColor),
                Center(
                  child: CLButtonText.large(
                    widget.buttonLabel,
                    color: widget.foregroundColor,
                    disabledColor: widget.disabledColor,
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        errorMessage = widget.onSubmit(
                          controllers
                              .map(
                                (e) => switch (e) {
                                  (final e)
                                      when e.runtimeType ==
                                          TextEditingController =>
                                    (e as TextEditingController).text,
                                  _ => ''
                                },
                              )
                              .toList(),
                        );
                        setState(() {});
                      }
                    },
                  ),
                ),
                if (isMobilePlatform && FocusScope.of(context).hasFocus)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CLButtonIcon.small(
                      Icons.keyboard_hide,
                      color: widget.foregroundColor,
                      disabledColor: widget.disabledColor,
                      onTap: () => FocusScope.of(context).unfocus(),
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
