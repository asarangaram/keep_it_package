import 'package:flutter/material.dart';

class CLErrorView extends StatelessWidget {
  const CLErrorView({Key? key, required this.errorMessage, this.errorDetails})
      : super(key: key);

  final String errorMessage;
  final String? errorDetails;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Column(
          children: [
            Text(
              errorMessage,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            if (errorDetails != null)
              Text(
                errorDetails!,
                maxLines: 5,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
