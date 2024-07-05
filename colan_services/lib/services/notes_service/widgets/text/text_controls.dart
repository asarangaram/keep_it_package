import 'package:flutter/material.dart';

class TextControls extends StatelessWidget {
  const TextControls({
    required this.controls,
    super.key,
  });

  final List<Widget> controls;

  @override
  Widget build(BuildContext context) {
    if (controls.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: double.infinity,
      width: kMinInteractiveDimension,
      child: controls.length > 1
          ? Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: controls,
            )
          : Center(
              child: controls[0],
            ),
    );
  }
}
