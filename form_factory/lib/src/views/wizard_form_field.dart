import 'package:colan_widgets/colan_widgets.dart' as cl;
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';
import 'package:form_factory/src/views/cl_form_select_single.dart';
import 'package:form_factory/src/views/cl_form_textfield.dart';

import '../models/cl_form_field_state.dart';
import 'cl_form_select_multiple.dart';

class CLWizardFormField extends StatefulWidget {
  const CLWizardFormField({
    required this.descriptor,
    required this.actionMenu,
    required this.onSubmit,
    super.key,
  });

  final void Function(CLFormFieldResult result) onSubmit;

  final CLFormFieldDescriptors descriptor;
  final cl.CLMenuItem Function(
    BuildContext context,
    Future<bool?> Function() onTap,
  )? actionMenu;
  @override
  State<CLWizardFormField> createState() => _CLWizardFormFieldState();
}

class _CLWizardFormFieldState extends State<CLWizardFormField> {
  late CLFormFieldState state;
  final GlobalKey wrapKey = GlobalKey();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    state = switch (widget.descriptor.runtimeType) {
      const (CLFormSelectMultipleDescriptors) => CLFormSelectMultipleState(
          scrollController: ScrollController(),
          wrapKey: wrapKey,
          searchController: SearchController(),
          selectedEntities:
              (widget.descriptor as CLFormSelectMultipleDescriptors)
                  .initialValues,
        ),
      const (CLFormSelectSingleDescriptors) => CLFormSelectSingleState(
          searchController: SearchController(),
          selectedEntitry: [
            (widget.descriptor as CLFormSelectSingleDescriptors).initialValues
          ],
        ),
      const (CLFormTextFieldDescriptor) => CLFormTextFieldState(
          controller: TextEditingController(), focusNode: FocusNode()),
      _ => throw UnimplementedError()
    };
    switch (widget.descriptor.runtimeType) {
      case const (CLFormSelectMultipleDescriptors):
      case const (CLFormSelectSingleDescriptors):
        break;
      case const (CLFormTextFieldDescriptor):
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
    final actionBuilder = widget.actionMenu == null
        ? null
        : (
            context,
          ) {
            final menuItem = widget.actionMenu!(context, () async {
              if (formKey.currentState?.validate() ?? false) {
                widget.onSubmit(switch (widget.descriptor.runtimeType) {
                  const (CLFormSelectMultipleDescriptors) =>
                    CLFormSelectMultipleResult(
                        (state as CLFormSelectMultipleState).selectedEntities),
                  const (CLFormSelectSingleDescriptors) =>
                    CLFormSelectSingleResult(
                        (state as CLFormSelectSingleState).selectedEntitry[0]!),
                  const (CLFormTextFieldDescriptor) => CLFormTextFieldResult(
                      (state as CLFormTextFieldState).controller.text),
                  _ => throw Exception("Unsupported")
                });
                return true;
              }
              return false;
            });
            return FractionallySizedBox(
              widthFactor: 0.2,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: CLTheme.of(context).colors.wizardButtonBackgroundColor,
                  border: Border.all(),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Align(
                  child: cl.CLButtonIconLabelled.standard(
                    menuItem.icon,
                    menuItem.title,
                    color: Theme.of(context).colorScheme.surface,
                    onTap: menuItem.onTap,
                  ),
                ),
              ),
            );
          };
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Form(
        key: formKey,
        child: SizedBox(
          width: double.infinity,
          height: kMinInteractiveDimension * 3,
          child: switch (widget.descriptor.runtimeType) {
            const (CLFormSelectMultipleDescriptors) => CLFormSelectMultiple(
                descriptors:
                    widget.descriptor as CLFormSelectMultipleDescriptors,
                state: (state as CLFormSelectMultipleState),
                onRefresh: () {
                  setState(() {});
                },
                actionBuilder: actionBuilder),
            const (CLFormSelectSingleDescriptors) => CLFormSelectSingle(
                descriptors: widget.descriptor as CLFormSelectSingleDescriptors,
                state: state as CLFormSelectSingleState,
                onRefresh: () {
                  setState(() {});
                },
                actionBuilder: actionBuilder,
              ),
            const (CLFormTextFieldDescriptor) => CLFormTextField(
                descriptors: widget.descriptor as CLFormTextFieldDescriptor,
                state: state as CLFormTextFieldState,
                onRefresh: () {
                  setState(() {});
                },
                actionBuilder: actionBuilder,
              ),
            _ => throw Exception("Unsupported")
          },
        ),
      ),
    );
  }
}
