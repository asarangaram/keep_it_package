import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'cl_text.dart';

class CLConfirmAction extends StatelessWidget {
  const CLConfirmAction({
    required this.title,
    required this.message,
    required this.child,
    required this.onConfirm,
    super.key,
  });

  final String title;
  final String message;
  final Widget? child;
  final void Function({
    required bool confirmed,
  }) onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: Alignment.center,
      title: Text(title),
      content: (child != null || message.isNotEmpty)
          ? SizedBox.square(
              dimension: 200,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                  child: Column(
                    children: [
                      Flexible(child: child ?? const SizedBox.shrink()),
                      if (message.isNotEmpty) CLText.large(message),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
      actions: [
        ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => onConfirm(confirmed: false),
              child: const Text('No'),
            ),
            ElevatedButton(
              child: const Text('Yes'),
              onPressed: () => onConfirm(confirmed: true),
            ),
          ],
        ),
      ],
    );
  }
}
