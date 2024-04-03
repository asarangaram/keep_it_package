import 'package:flutter/material.dart';

class ConfirmAction extends StatelessWidget {
  const ConfirmAction({
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
      title: const Text('Confirm Delete'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (child != null)
            SizedBox.square(
              dimension: 200,
              child: child,
            ),
          Text(message),
        ],
      ),
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
