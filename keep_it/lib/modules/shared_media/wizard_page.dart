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
    required void Function()? onCancel,
    CLMenuItem? option1,
    CLMenuItem? option2,
    CLMenuItem? option3,
  }) {
    /*  
          Do we need ClipRRect?? 
          
          */
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: CLTheme.of(context).colors.wizardButtonBackgroundColor,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 14,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Stack(
                      children: [
                        Positioned.fill(child: CLText.large(title)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: CLTheme.of(context)
                                  .colors
                                  .iconBackgroundTransparent,
                            ),
                            child: CLButtonIcon.small(
                              Icons.close,
                              color: CLTheme.of(context)
                                  .colors
                                  .iconColorTransparent,
                              onTap: onCancel,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(child: child),
                ],
              ),
            ),
            const Divider(
              height: 16,
              thickness: 1,
              indent: 8,
              endIndent: 8,
              color: Colors.black,
            ),
            Expanded(
              flex: 5,
              child: WizardDialog(
                option1: option1 == null
                    ? null
                    : CLButtonText.large(
                        option1.title,
                        onTap: option1.onTap,
                        color: CLTheme.of(context)
                            .colors
                            .wizardButtonForegroundColor,
                      ),
                option2: option2 == null
                    ? null
                    : CLButtonText.large(
                        option2.title,
                        onTap: option2.onTap,
                        color: CLTheme.of(context)
                            .colors
                            .wizardButtonForegroundColor,
                      ),
                option3: (option3 == null)
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(right: 16, top: 8),
                        child: Row(
                          children: [
                            const Spacer(),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: CLTheme.of(context)
                                      .colors
                                      .wizardButtonBackgroundColor,
                                  border: Border.all(
                                    color: CLTheme.of(context)
                                        .colors
                                        .wizardButtonBackgroundColor,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(16)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: CLButtonText.large(
                                    option3.title,
                                    onTap: option3.onTap,
                                    color: CLTheme.of(context)
                                        .colors
                                        .wizardButtonForegroundColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
    this.option3,
    super.key,
  });
  final Widget content;
  final Widget? option1;
  final Widget? option2;
  final Widget? option3;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (option3 != null) option3!,
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
                      : Container(
                          margin: const EdgeInsets.only(right: 1),
                          decoration: BoxDecoration(
                            color: CLTheme.of(context)
                                .colors
                                .wizardButtonBackgroundColor,
                            border: const Border(
                              top: BorderSide(
                                color: Colors.transparent,
                              ),
                              right: BorderSide(
                                color: Colors.transparent,
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
                      : Container(
                          margin: const EdgeInsets.only(left: 1),
                          decoration: BoxDecoration(
                            color: CLTheme.of(context)
                                .colors
                                .wizardButtonBackgroundColor,
                            border: const Border(
                              top: BorderSide(
                                color: Colors.transparent,
                              ),
                              left: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8, left: 2),
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
