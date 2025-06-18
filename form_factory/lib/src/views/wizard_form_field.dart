import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';
import 'package:form_factory/src/views/cl_form_select_single.dart';
import 'package:form_factory/src/views/cl_form_textfield.dart';

import '../models/cl_form_field_state.dart';

import 'cl_form_select_multiple.dart';

class CLWizardFormField extends StatefulWidget {
  const CLWizardFormField({
    required this.descriptor,
    required this.onSubmit,
    super.key,
  });

  final void Function(CLFormFieldResult result) onSubmit;

  final CLFormFieldDescriptors descriptor;
  @override
  State<CLWizardFormField> createState() => _CLWizardFormFieldState();
}

class _CLWizardFormFieldState extends State<CLWizardFormField> {
  late CLFormFieldState state;
  final GlobalKey wrapKey = GlobalKey();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    state = switch (widget.descriptor) {
      CLFormSelectMultipleDescriptors _ => CLFormSelectMultipleState(
          scrollController: ScrollController(),
          wrapKey: wrapKey,
          searchController: SearchController(),
          selectedEntities:
              (widget.descriptor as CLFormSelectMultipleDescriptors)
                  .initialValues,
        ),
      CLFormSelectSingleDescriptors _ => CLFormSelectSingleState(
          searchController: SearchController(),
          selectedEntitry: [
            (widget.descriptor as CLFormSelectSingleDescriptors).initialValues
          ],
        ),
      CLFormTextFieldDescriptor _ => CLFormTextFieldState(
          controller: TextEditingController(), focusNode: FocusNode()),
      _ => throw UnimplementedError()
    };
    switch (widget.descriptor) {
      case CLFormSelectMultipleDescriptors _:
      case CLFormSelectSingleDescriptors _:
        break;
      case CLFormTextFieldDescriptor _:
        (state as CLFormTextFieldState).focusNode?.requestFocus();
    }

    super.initState();
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: kMinInteractiveDimension * 4,
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InputDecorator(
            decoration: FormDesign.inputDecoration(context,
                label: widget.descriptor.label,
                borderRadius: BorderRadius.all(Radius.circular(16))),
            child: switch (widget.descriptor) {
              CLFormSelectMultipleDescriptors _ => CLFormSelectMultiple(
                  descriptors:
                      widget.descriptor as CLFormSelectMultipleDescriptors,
                  state: (state as CLFormSelectMultipleState),
                  onRefresh: () {
                    setState(() {});
                  }),
              CLFormSelectSingleDescriptors _ => CLFormSelectSingle(
                  descriptors:
                      widget.descriptor as CLFormSelectSingleDescriptors,
                  state: state as CLFormSelectSingleState,
                  onRefresh: () {
                    setState(() {});
                  }),
              CLFormTextFieldDescriptor _ => CLFormTextField(
                  descriptors: widget.descriptor as CLFormTextFieldDescriptor,
                  state: state as CLFormTextFieldState,
                  onRefresh: () {
                    setState(() {});
                  }),
              _ => throw Exception("Unsupported")
            },
          ),
        ),
      ),
    );
  }
}
