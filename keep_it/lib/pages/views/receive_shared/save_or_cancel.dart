import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SaveOrCancel extends ConsumerWidget {
  const SaveOrCancel({
    super.key,
    required this.onSave,
    required this.onDiscard,
    this.saveLabel,
    this.cancelLabel,
  });
  final String? saveLabel;
  final String? cancelLabel;
  final Function() onDiscard;
  final Function()? onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onSave == null)
          const CircularProgressIndicator()
        else
          Flexible(
            child: Center(
              child: CLButtonText.veryLarge(
                saveLabel ?? "Save",
                onTap: onSave,
              ),
            ),
          ),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(), //incase of keyboard, implement this.
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CLButtonText.small(
                  cancelLabel ?? "Cancel",
                  onTap: onDiscard,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
