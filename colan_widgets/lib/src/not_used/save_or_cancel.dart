/* import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SaveOrCancel extends ConsumerWidget {
  const SaveOrCancel({
    required this.onSave,
    required this.onDiscard,
    super.key,
    this.saveLabel,
    this.cancelLabel,
    this.canSave = true,
  });
  final String? saveLabel;
  final String? cancelLabel;
  final void Function() onDiscard;
  final void Function()? onSave;
  final bool canSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (canSave)
          if (onSave == null)
            const CircularProgressIndicator()
          else
            Flexible(
              child: Center(
                child: CLButtonText.veryLarge(
                  saveLabel ?? 'Save',
                  onTap: onSave,
                ),
              ),
            ),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (FocusScope.of(context).hasFocus)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CLButtonIcon.small(
                    clIcons.keyboard_hide_outlined,
                    onTap: () => FocusScope.of(context).unfocus(),
                  ),
                )
              else
                Container(), //incase of keyboard, implement this.
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CLButtonText.small(
                  cancelLabel ?? 'Cancel',
                  onTap: onDiscard,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
 */
