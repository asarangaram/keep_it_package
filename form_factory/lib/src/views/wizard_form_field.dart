import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:form_factory/form_factory.dart';

import '../models/cl_form_field_state.dart';
import 'action_button.dart' show ActionButton;

class CLWizardFormField extends StatefulWidget implements PreferredSizeWidget {
  const CLWizardFormField(
      {required this.descriptor,
      required this.onSubmit,
      super.key,
      this.rightControl,
      this.leftControl,
      this.backgroundColor,
      this.foregroundColor,
      this.mutedForegroundColor,
      this.footerText});

  final void Function(CLFormFieldResult result) onSubmit;
  final CLFormFieldDescriptors descriptor;

  final CLMenuItemBase? leftControl;
  final CLMenuItemBase? rightControl;

  final Color? foregroundColor;
  final Color? mutedForegroundColor;
  final Color? backgroundColor;
  final String? footerText;

  @override
  State<CLWizardFormField> createState() => _CLWizardFormFieldState();

  @override
  Size get preferredSize => Size(double.infinity, kMinInteractiveDimension * 2);
}

class _CLWizardFormFieldState extends State<CLWizardFormField> {
  late CLFormFieldState state;
  CLMenuItemBase? rightControl;
  CLMenuItemBase? leftControl;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    state = widget.descriptor.createState(onUpdateResult: onUpdateResult);
    controls();
    super.initState();
  }

  void onUpdateResult() {
    setState(() {
      controls();
    });
  }

  @override
  void dispose() {
    widget.descriptor.disposeState(state);
    super.dispose();
  }

  Radius get leftRadius =>
      widget.leftControl != null ? Radius.zero : Radius.circular(16);
  Radius get rightRadius =>
      widget.rightControl != null ? Radius.zero : Radius.circular(16);

  BorderRadius get borderRadius => BorderRadius.only(
      topLeft: leftRadius,
      bottomLeft: leftRadius,
      topRight: rightRadius,
      bottomRight: rightRadius);
  int get flex =>
      6 +
      ((widget.leftControl != null) ? 0 : 1) +
      ((widget.rightControl != null) ? 0 : 1);

  void controls() {
    switch (widget.rightControl) {
      case CLMenuItem item when item.onTap == null:
        if (((formKey.currentState?.validate() ?? true))) {
          rightControl = item.copyWith(
            onTap: () async {
              widget.onSubmit(state.result);
              return true;
            },
          );
        } else {
          rightControl = widget.rightControl;
        }

      default:
        rightControl = widget.rightControl;
    }

    leftControl = widget.leftControl;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.preferredSize.height,
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: flex,
                child: InputDecorator(
                  decoration: FormDesign.inputDecoration(context,
                      label: widget.descriptor.label,
                      borderRadius: borderRadius),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: state.formField(context,
                            onRefresh: onUpdateResult));
                  }),
                ),
              ),
              if (rightControl != null)
                Expanded(
                  child: ActionButton.right(
                      backgroundColor: widget.backgroundColor,
                      foregroundColor: widget.foregroundColor,
                      foregroundDisabledColor: widget.mutedForegroundColor,
                      menuItem: rightControl!),
                )
            ],
          ),
        ),
      ),
    );
  }
}
