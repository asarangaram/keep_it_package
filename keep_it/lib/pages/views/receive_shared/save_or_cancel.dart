import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/theme.dart';

class SaveOrCancel extends ConsumerWidget {
  const SaveOrCancel({
    super.key,
    required this.onSave,
    required this.onDiscard,
  });
  final Function() onDiscard;
  final Function() onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Center(
            child: CLButtonText.large(
              "Save",
              color: theme.colorTheme.buttonText,
              disabledColor: theme.colorTheme.disabledColor,
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
                  "Cancel",
                  color: theme.colorTheme.textColor,
                  disabledColor: theme.colorTheme.disabledColor,
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
