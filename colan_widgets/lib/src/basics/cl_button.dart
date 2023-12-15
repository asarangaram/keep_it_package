// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:colan_widgets/src/basics/cl_icon.dart';
import 'package:colan_widgets/src/basics/cl_text.dart';
import 'package:colan_widgets/src/models/cl_scale_type.dart';
import 'package:flutter/material.dart';

class _CLButton extends StatelessWidget {
  final IconData? iconData;
  final String? label;
  final Color color;
  final Color disabledColor;
  final CLScaleType scaleType;
  final Function()? onTap;

  const _CLButton(
      {super.key,
      required this.iconData,
      required this.label,
      required this.color,
      required this.disabledColor,
      required this.scaleType,
      this.onTap});

  Color get color_ => onTap == null ? disabledColor : color;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: switch (iconData) {
          null => switch (scaleType) {
              CLScaleType.veryLarge => CLLabel.veryLarge,
              CLScaleType.large => CLLabel.large,
              CLScaleType.standard => CLLabel.standard,
              CLScaleType.small => CLLabel.small,
              CLScaleType.verySmall => CLLabel.verySmall,
              CLScaleType.tiny => CLLabel.tiny,
            }(label!, color: color_),
          _ => switch (label) {
              null => switch (scaleType) {
                  CLScaleType.veryLarge => CLIcon.veryLarge,
                  CLScaleType.large => CLIcon.large,
                  CLScaleType.standard => CLIcon.standard,
                  CLScaleType.small => CLIcon.small,
                  CLScaleType.verySmall => CLIcon.verySmall,
                  CLScaleType.tiny => CLIcon.tiny,
                }(iconData!, color: color_),
              _ => switch (scaleType) {
                  CLScaleType.veryLarge => CLIconLabelled.veryLarge,
                  CLScaleType.large => CLIconLabelled.large,
                  CLScaleType.standard => CLIconLabelled.standard,
                  CLScaleType.small => CLIconLabelled.small,
                  CLScaleType.verySmall => CLIconLabelled.verySmall,
                  CLScaleType.tiny => CLIconLabelled.tiny,
                }(iconData!, label!, color: color_)
            },
        });
  }
}

class CLButtonText extends _CLButton {
  const CLButtonText.veryLarge(
    String label, {
    super.key,
    required super.color,
    required super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: null, scaleType: CLScaleType.veryLarge);
  const CLButtonText.large(
    String label, {
    super.key,
    required super.color,
    required super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: null, scaleType: CLScaleType.large);
  const CLButtonText.standard(
    String label, {
    super.key,
    required super.color,
    required super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: null, scaleType: CLScaleType.standard);
  const CLButtonText.small(
    String label, {
    super.key,
    required super.color,
    required super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: null, scaleType: CLScaleType.small);
  const CLButtonText.verySmall(
    String label, {
    super.key,
    required super.color,
    required super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: null, scaleType: CLScaleType.verySmall);
  const CLButtonText.tiny(
    String label, {
    super.key,
    required super.color,
    required super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: null, scaleType: CLScaleType.tiny);
}

class CLButtonIcon extends _CLButton {
  const CLButtonIcon.veryLarge(
    IconData iconData, {
    super.key,
    required super.color,
    required super.disabledColor,
    super.onTap,
  }) : super(label: null, iconData: iconData, scaleType: CLScaleType.veryLarge);
  const CLButtonIcon.large(
    IconData iconData, {
    super.key,
    required super.color,
    required super.disabledColor,
    super.onTap,
  }) : super(label: null, iconData: iconData, scaleType: CLScaleType.large);
  const CLButtonIcon.standard(
    IconData iconData, {
    super.key,
    required super.color,
    required super.disabledColor,
    super.onTap,
  }) : super(label: null, iconData: iconData, scaleType: CLScaleType.standard);
  const CLButtonIcon.small(
    IconData iconData, {
    super.key,
    required super.color,
    required super.disabledColor,
    super.onTap,
  }) : super(label: null, iconData: iconData, scaleType: CLScaleType.small);
  const CLButtonIcon.verySmall(
    IconData iconData, {
    super.key,
    required super.color,
    required super.disabledColor,
    super.onTap,
  }) : super(label: null, iconData: iconData, scaleType: CLScaleType.verySmall);
  const CLButtonIcon.tiny(
    IconData iconData, {
    super.key,
    required super.color,
    required super.disabledColor,
    super.onTap,
  }) : super(label: null, iconData: iconData, scaleType: CLScaleType.tiny);
}

class CLButtonIconLabelled extends _CLButton {
  const CLButtonIconLabelled.veryLarge(
    IconData iconData,
    String label, {
    super.key,
    required super.color,
    required super.disabledColor,
    super.onTap,
  }) : super(
            label: label, iconData: iconData, scaleType: CLScaleType.veryLarge);
  const CLButtonIconLabelled.large(
    IconData iconData,
    String label, {
    super.key,
    required super.color,
    required super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: iconData, scaleType: CLScaleType.large);
  const CLButtonIconLabelled.standard(
    IconData iconData,
    String label, {
    super.key,
    required super.color,
    required super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: iconData, scaleType: CLScaleType.standard);
  const CLButtonIconLabelled.small(
    IconData iconData,
    String label, {
    super.key,
    required super.color,
    required super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: iconData, scaleType: CLScaleType.small);
  const CLButtonIconLabelled.verySmall(
    IconData iconData,
    String label, {
    super.key,
    required super.color,
    required super.disabledColor,
    super.onTap,
  }) : super(
            label: label, iconData: iconData, scaleType: CLScaleType.verySmall);
  const CLButtonIconLabelled.tiny(
    IconData iconData,
    String label, {
    super.key,
    required super.color,
    required super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: iconData, scaleType: CLScaleType.tiny);
}
