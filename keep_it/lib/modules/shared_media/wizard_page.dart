import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class SharedMediaWizard extends ConsumerWidget {
  const SharedMediaWizard({
    required this.incomingMedia,
    required this.onDone,
    required this.onCancel,
    super.key,
  });
  final CLSharedMedia incomingMedia;
  final void Function({required CLSharedMedia? mg}) onDone;
  final void Function() onCancel;

  static Widget buildWizard(
    BuildContext context,
    WidgetRef ref, {
    required Widget child,
    required String message,
    required String title,
    CLMenuItem? option1,
    CLMenuItem? option2,
  }) {
    /* decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ), 
          Do we need ClipRRect?? 
          */
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: CLText.large(title),
            ),
            Expanded(
              flex: 14,
              child: child,
            ),
            Expanded(
              flex: 5,
              child: WizardDialog(
                option1: option1 == null
                    ? null
                    : CLButtonText.large(
                        option1.title,
                        onTap: option1.onTap,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                option2: option2 == null
                    ? null
                    : CLButtonText.large(
                        option2.title,
                        onTap: option2.onTap,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                content: Center(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: CLScaleType.standard.fontSize,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WizardDialog extends StatelessWidget {
  const WizardDialog({
    required this.content,
    this.option1,
    this.option2,
    super.key,
  });
  final Widget content;
  final Widget? option1;
  final Widget? option2;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: content,
            ),
          ),
        ),
        if (option1 != null || option2 != null)
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: (option2 == null)
                      ? Container()
                      : DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface,
                            border: Border(
                              top: BorderSide(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              right: BorderSide(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: option2,
                            ),
                          ),
                        ),
                ),
                Expanded(
                  child: (option1 == null)
                      ? Container()
                      : DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface,
                            border: Border(
                              top: BorderSide(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              left: BorderSide(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: option1,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
