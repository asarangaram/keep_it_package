import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OnCloseButton extends StatelessWidget {
  const OnCloseButton({super.key, required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      child: Icon(Icons.arrow_back_ios, color: iconColor),
      onPressed: () {},
    );
  }
}
