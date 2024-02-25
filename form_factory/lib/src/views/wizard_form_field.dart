import 'package:colan_widgets/colan_widgets.dart' as cl;
import 'package:flutter/material.dart';

import '../models/cl_form_field_descriptors.dart';
import '../models/cl_form_field_result.dart';
import '../models/cl_form_field_state.dart';
import 'cl_form_select.dart';

class CLWizardFormField extends StatefulWidget {
  const CLWizardFormField({
    required this.onSubmit,
    required this.descriptor,
    required this.actionMenu,
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
  late CLFormSelectMultipleState state;
  final GlobalKey wrapKey = GlobalKey();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    state = CLFormSelectMultipleState(
      scrollController: ScrollController(),
      wrapKey: wrapKey,
      searchController: SearchController(),
      selectedEntities:
          (widget.descriptor as CLFormSelectMultipleDescriptors).initialValues,
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
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Form(
        key: formKey,
        child: SizedBox.expand(
          child: CLFormSelectMultiple(
            descriptors: widget.descriptor as CLFormSelectMultipleDescriptors,
            state: state,
            onRefresh: () {
              setState(() {});
            },
            actionBuilder: widget.actionMenu == null
                ? null
                : (
                    context,
                  ) {
                    final menuItem = widget.actionMenu!(context, () async {
                      if (formKey.currentState?.validate() ?? false) {
                        widget.onSubmit(
                          CLFormSelectMultipleResult(state.selectedEntities),
                        );
                      }
                      return null;
                    });
                    return FractionallySizedBox(
                      widthFactor: 0.2,
                      heightFactor: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface,
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
                  },
          ),
        ),
      ),
    );
  }
}
