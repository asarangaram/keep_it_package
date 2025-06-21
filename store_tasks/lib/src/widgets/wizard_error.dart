import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class WizardError extends StatefulWidget {
  const WizardError({super.key, this.error});
  final String? error;

  @override
  State<WizardError> createState() => _WizardErrorState();
}

class _WizardErrorState extends State<WizardError> {
  final popoverController = ShadPopoverController();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Text(
            'Something went wrong.',
            style: ShadTheme.of(context)
                .textTheme
                .list
                .copyWith(color: ShadTheme.of(context).colorScheme.destructive),
          ),
          ShadPopover(
            controller: popoverController,
            popover: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Text(
                    widget.error ?? 'Unknown error',
                  ),
                ],
              );
            },
            child: ShadButton.ghost(
                onPressed: popoverController.toggle,
                child: const Text(
                  'Details',
                )),
          ),
          ShadButton.secondary(
              child: Text(
            'Close',
            style: ShadTheme.of(context)
                .textTheme
                .list
                .copyWith(color: ShadTheme.of(context).colorScheme.destructive),
          )),
        ],
      ),
    );
  }
}
