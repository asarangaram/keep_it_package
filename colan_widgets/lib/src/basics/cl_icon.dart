import 'package:colan_widgets/src/basics/cl_text.dart';
import 'package:flutter/material.dart';

import '../models/cl_scale_type.dart';

class _CLIcon extends StatelessWidget {
  final IconData iconData;
  final String? text;
  final CLScaleType scaleType;
  final Color color;

  const _CLIcon(
    this.iconData, {
    super.key,
    required this.text,
    required this.scaleType,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (text == null) {
      return Icon(
        iconData,
        color: color,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          iconData,
          color: color,
          size: scaleType.iconSize,
        ),
        switch (scaleType) {
          CLScaleType.veryLarge => CLLabel.veryLarge,
          CLScaleType.large => CLLabel.large,
          CLScaleType.standard => CLLabel.standard,
          CLScaleType.small => CLLabel.small,
          CLScaleType.verySmall => CLLabel.verySmall,
          CLScaleType.tiny => CLLabel.tiny,
        }(text!, color: color)
      ],
    );
  }
}

class CLIcon extends _CLIcon {
  const CLIcon.veryLarge(super.iconData, {super.key, required super.color})
      : super(text: null, scaleType: CLScaleType.veryLarge);
  const CLIcon.large(super.iconData, {super.key, required super.color})
      : super(text: null, scaleType: CLScaleType.large);

  const CLIcon.standard(super.iconData, {super.key, required super.color})
      : super(text: null, scaleType: CLScaleType.standard);
  const CLIcon.small(super.iconData, {super.key, required super.color})
      : super(text: null, scaleType: CLScaleType.small);
  const CLIcon.verySmall(super.iconData, {super.key, required super.color})
      : super(text: null, scaleType: CLScaleType.verySmall);
  const CLIcon.tiny(super.iconData, {super.key, required super.color})
      : super(text: null, scaleType: CLScaleType.tiny);
}

class CLIconLabelled extends _CLIcon {
  const CLIconLabelled.veryLarge(super.iconData, String text,
      {super.key, required super.color})
      : super(text: text, scaleType: CLScaleType.veryLarge);
  const CLIconLabelled.large(super.iconData, String text,
      {super.key, required super.color})
      : super(text: text, scaleType: CLScaleType.large);
  const CLIconLabelled.standard(super.iconData, String text,
      {super.key, required super.color})
      : super(text: text, scaleType: CLScaleType.standard);
  const CLIconLabelled.small(super.iconData, String text,
      {super.key, required super.color})
      : super(text: text, scaleType: CLScaleType.small);
  const CLIconLabelled.verySmall(super.iconData, String text,
      {super.key, required super.color})
      : super(text: text, scaleType: CLScaleType.verySmall);
  const CLIconLabelled.tiny(super.iconData, String text,
      {super.key, required super.color})
      : super(text: text, scaleType: CLScaleType.tiny);
}
