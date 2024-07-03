import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class WizardDialog extends StatelessWidget {
  const WizardDialog({
    required this.content,
    this.option1,
    this.option2,
    this.option3,
    super.key,
  });
  final Widget content;
  final CLMenuItem? option1;
  final CLMenuItem? option2;
  final CLMenuItem? option3;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (option3 != null)
          Padding(
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
                        Radius.circular(16),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: CLButtonText.large(
                        option3!.title,
                        onTap: option3!.onTap,
                        color: CLTheme.of(context)
                            .colors
                            .wizardButtonForegroundColor,
                        disabledColor: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                              child: CLButtonText.large(
                                option2!.title,
                                onTap: option2!.onTap,
                                color: CLTheme.of(context)
                                    .colors
                                    .wizardButtonForegroundColor,
                                disabledColor: Colors.grey,
                              ),
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
                              child: CLButtonText.large(
                                option1!.title,
                                onTap: option1!.onTap,
                                color: CLTheme.of(context)
                                    .colors
                                    .wizardButtonForegroundColor,
                                disabledColor: Colors.grey,
                              ),
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
