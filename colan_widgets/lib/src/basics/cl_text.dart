// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../models/cl_scale_type.dart';

class _CLText extends StatelessWidget {
  final String text;
  final CLScaleType scaleType;
  final Color color;
  final bool isLabel;
  const _CLText(
    this.text, {
    super.key,
    required this.scaleType,
    required this.color,
    required this.isLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text,
        maxLines: isLabel ? 1 : null,
        overflow: isLabel ? TextOverflow.ellipsis : null,
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: color, fontSize: scaleType.fontSize));
  }
}

class CLText extends _CLText {
  const CLText.standard(super.text, {super.key, required super.color})
      : super(isLabel: false, scaleType: CLScaleType.standard);
  const CLText.veryLarge(super.text, {super.key, required super.color})
      : super(isLabel: false, scaleType: CLScaleType.veryLarge);
  const CLText.large(super.text, {super.key, required super.color})
      : super(isLabel: false, scaleType: CLScaleType.large);
  const CLText.small(super.text, {super.key, required super.color})
      : super(isLabel: false, scaleType: CLScaleType.small);
  const CLText.verySmall(super.text, {super.key, required super.color})
      : super(isLabel: false, scaleType: CLScaleType.verySmall);
  const CLText.tiny(super.text, {super.key, required super.color})
      : super(isLabel: false, scaleType: CLScaleType.tiny);
}

class CLLabel extends _CLText {
  const CLLabel.standard(super.text, {super.key, required super.color})
      : super(isLabel: true, scaleType: CLScaleType.standard);
  const CLLabel.veryLarge(super.text, {super.key, required super.color})
      : super(isLabel: true, scaleType: CLScaleType.veryLarge);
  const CLLabel.large(super.text, {super.key, required super.color})
      : super(isLabel: true, scaleType: CLScaleType.large);
  const CLLabel.small(super.text, {super.key, required super.color})
      : super(isLabel: true, scaleType: CLScaleType.small);
  const CLLabel.verySmall(super.text, {super.key, required super.color})
      : super(isLabel: true, scaleType: CLScaleType.verySmall);
  const CLLabel.tiny(super.text, {super.key, required super.color})
      : super(isLabel: true, scaleType: CLScaleType.tiny);
}
