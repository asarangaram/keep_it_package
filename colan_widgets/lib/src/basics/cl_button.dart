// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:colan_widgets/src/basics/cl_icon.dart';
import 'package:colan_widgets/src/basics/cl_text.dart';
import 'package:colan_widgets/src/models/cl_scale_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _CLButton extends StatelessWidget {
  final IconData? iconData;
  final String? label;
  final Color? color;
  final Color? disabledColor;
  final CLScaleType scaleType;
  final Function()? onTap;
  final BoxDecoration? boxDecoration;

  const _CLButton({
    super.key,
    required this.iconData,
    required this.label,
    this.color,
    this.disabledColor,
    required this.scaleType,
    this.onTap,
    this.boxDecoration,
  });

  Color? get color_ => onTap == null ? disabledColor : color;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap ?? () => showSnackBarAboveDialog(context, label ?? "Icon"),
        child: ButtonBackground(
          boxDecoration: boxDecoration,
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
          },
        ));
  }

  // TODO: Merge from another object
  static void showSnackBarAboveDialog(BuildContext context, String message,
      {Duration duration = const Duration(milliseconds: 400)}) {
    // Create an overlay entry
    OverlayEntry entry;

    entry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        top: MediaQuery.of(context).size.height *
            0.8, // Adjust position as needed
        width: MediaQuery.of(context).size.width,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration:
                  BoxDecoration(color: Theme.of(context).colorScheme.onSurface),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CLText.large(
                  message,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Insert the overlay entry above the current overlay entries (dialogs)
    Overlay.of(context).insert(entry);

    // Remove the overlay entry after a certain duration
    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  }
}

class ButtonBackground extends ConsumerWidget {
  const ButtonBackground({
    super.key,
    required this.child,
    this.boxDecoration,
  });
  final Widget child;
  final BoxDecoration? boxDecoration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (boxDecoration == null) {
      return child;
    }
    return Container(
      decoration: boxDecoration!,
      child: Center(child: child),
    );
  }
}

class CLButtonText extends _CLButton {
  const CLButtonText.veryLarge(
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: null, scaleType: CLScaleType.veryLarge);
  const CLButtonText.large(
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: null, scaleType: CLScaleType.large);
  const CLButtonText.standard(
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: null, scaleType: CLScaleType.standard);
  const CLButtonText.small(
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: null, scaleType: CLScaleType.small);
  const CLButtonText.verySmall(
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: null, scaleType: CLScaleType.verySmall);
  const CLButtonText.tiny(
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: null, scaleType: CLScaleType.tiny);
}

class CLButtonIcon extends _CLButton {
  const CLButtonIcon.veryLarge(
    IconData iconData, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: null, iconData: iconData, scaleType: CLScaleType.veryLarge);
  const CLButtonIcon.large(
    IconData iconData, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: null, iconData: iconData, scaleType: CLScaleType.large);
  const CLButtonIcon.standard(
    IconData iconData, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: null, iconData: iconData, scaleType: CLScaleType.standard);
  const CLButtonIcon.small(
    IconData iconData, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: null, iconData: iconData, scaleType: CLScaleType.small);
  const CLButtonIcon.verySmall(
    IconData iconData, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: null, iconData: iconData, scaleType: CLScaleType.verySmall);
  const CLButtonIcon.tiny(
    IconData iconData, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: null, iconData: iconData, scaleType: CLScaleType.tiny);
}

class CLButtonIconLabelled extends _CLButton {
  const CLButtonIconLabelled.veryLarge(
    IconData iconData,
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(
            label: label, iconData: iconData, scaleType: CLScaleType.veryLarge);
  const CLButtonIconLabelled.large(
    IconData iconData,
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: iconData, scaleType: CLScaleType.large);
  const CLButtonIconLabelled.standard(
    IconData iconData,
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: iconData, scaleType: CLScaleType.standard);
  const CLButtonIconLabelled.small(
    IconData iconData,
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: iconData, scaleType: CLScaleType.small);
  const CLButtonIconLabelled.verySmall(
    IconData iconData,
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(
            label: label, iconData: iconData, scaleType: CLScaleType.verySmall);
  const CLButtonIconLabelled.tiny(
    IconData iconData,
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
  }) : super(label: label, iconData: iconData, scaleType: CLScaleType.tiny);
}

class CLButtonElevatedText extends _CLButton {
  const CLButtonElevatedText.veryLarge(
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
    required BoxDecoration boxDecoration,
  }) : super(
            label: label,
            iconData: null,
            scaleType: CLScaleType.veryLarge,
            boxDecoration: boxDecoration);
  const CLButtonElevatedText.large(
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
    required BoxDecoration boxDecoration,
  }) : super(
            label: label,
            iconData: null,
            scaleType: CLScaleType.large,
            boxDecoration: boxDecoration);
  const CLButtonElevatedText.standard(
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
    required BoxDecoration boxDecoration,
  }) : super(
            label: label,
            iconData: null,
            scaleType: CLScaleType.standard,
            boxDecoration: boxDecoration);
  const CLButtonElevatedText.small(
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
    required BoxDecoration boxDecoration,
  }) : super(
            label: label,
            iconData: null,
            scaleType: CLScaleType.small,
            boxDecoration: boxDecoration);
  const CLButtonElevatedText.verySmall(
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
    required BoxDecoration boxDecoration,
  }) : super(
            label: label,
            iconData: null,
            scaleType: CLScaleType.verySmall,
            boxDecoration: boxDecoration);
  const CLButtonElevatedText.tiny(
    String label, {
    super.key,
    super.color,
    super.disabledColor,
    super.onTap,
    required BoxDecoration boxDecoration,
  }) : super(
            label: label,
            iconData: null,
            scaleType: CLScaleType.tiny,
            boxDecoration: boxDecoration);
}

class _CLButtonElevated extends StatelessWidget {
  const _CLButtonElevated({
    super.key,
    required this.child,
    this.onTap,
    required this.scaleType,
  });
  final Widget child;
  final void Function()? onTap;
  final CLScaleType scaleType;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: scaleType.fontSize * 8,
        height: scaleType.fontSize * 8,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: Card(
                elevation: 12,
                shape: const ContinuousRectangleBorder(),
                margin: const EdgeInsets.all(0),
                child: InkWell(
                  onTap: onTap,
                  child: Align(
                    alignment: Alignment.center,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CLButtonElevated extends _CLButtonElevated {
  const CLButtonElevated.veryLarge(
      {super.key, required super.child, super.onTap})
      : super(scaleType: CLScaleType.veryLarge);
  const CLButtonElevated.large({super.key, required super.child, super.onTap})
      : super(scaleType: CLScaleType.large);
  const CLButtonElevated.standard(
      {super.key, required super.child, super.onTap})
      : super(scaleType: CLScaleType.standard);
  const CLButtonElevated.small({super.key, required super.child, super.onTap})
      : super(scaleType: CLScaleType.small);
  const CLButtonElevated.verySmall(
      {super.key, required super.child, super.onTap})
      : super(scaleType: CLScaleType.verySmall);
  const CLButtonElevated.tiny({super.key, required super.child, super.onTap})
      : super(scaleType: CLScaleType.tiny);
}
