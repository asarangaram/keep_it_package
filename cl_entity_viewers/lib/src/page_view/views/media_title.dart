import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MediaTitle extends StatelessWidget {
  const MediaTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Title here', style: ShadTheme.of(context).textTheme.h3),
        Text('29 Apr, 2026', style: ShadTheme.of(context).textTheme.small),
      ],
    );
  }
}
