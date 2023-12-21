import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../basics/cl_button.dart';
import '../basics/cl_icon.dart';
import '../basics/cl_text.dart';
import '../models/cl_scale_type.dart';
import 'cl_quickmenu.dart';

class CLButtonsGrid extends ConsumerWidget {
  const CLButtonsGrid(
      {super.key,
      required this.clMenuItems2D,
      this.scaleType = CLScaleType.standard})
      : onCancelNullable = null,
        isDialog = false;
  const CLButtonsGrid.dialog(
      {super.key,
      required this.clMenuItems2D,
      required Function() onCancel,
      this.scaleType = CLScaleType.standard})
      : onCancelNullable = onCancel,
        isDialog = true;
  final List<List<CLMenuItem>> clMenuItems2D;
  final Function()? onCancelNullable;
  final CLScaleType scaleType;
  final bool isDialog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final length =
        clMenuItems2D.map((e) => e.length).reduce((a, b) => a > b ? a : b);
    return CLDialogWrapper(
      isDialog: isDialog,
      onCancel: onCancelNullable,
      child: SizedBox(
        height: isDialog
            ? clMenuItems2D.length * kMinInteractiveDimension * 4
            : null,
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var clMenuItems1D in clMenuItems2D)
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < clMenuItems1D.length; i++)
                        Expanded(
                          child: switch (scaleType) {
                            CLScaleType.veryLarge => CLButtonElevated.veryLarge,
                            CLScaleType.large => CLButtonElevated.large,
                            CLScaleType.standard => CLButtonElevated.standard,
                            CLScaleType.small => CLButtonElevated.small,
                            CLScaleType.verySmall => CLButtonElevated.verySmall,
                            CLScaleType.tiny => CLButtonElevated.tiny,
                          }(
                            onTap: clMenuItems1D[i].onTap ??
                                () {
                                  showSnackBarAboveDialog(
                                      context, clMenuItems1D[i].title);
                                },
                            child: switch (scaleType) {
                              CLScaleType.veryLarge => CLIconLabelled.veryLarge,
                              CLScaleType.large => CLIconLabelled.large,
                              CLScaleType.standard => CLIconLabelled.standard,
                              CLScaleType.small => CLIconLabelled.small,
                              CLScaleType.verySmall => CLIconLabelled.verySmall,
                              CLScaleType.tiny => CLIconLabelled.tiny,
                            }(
                              clMenuItems1D[i].icon,
                              clMenuItems1D[i].title,
                            ),
                          ),
                        ),
                      for (var i = clMenuItems1D.length; i < length; i++)
                        Expanded(child: Container())
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

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

/*

child: 
                     */