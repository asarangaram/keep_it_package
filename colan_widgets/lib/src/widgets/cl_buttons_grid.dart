import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../basics/cl_button.dart';
import '../basics/cl_icon.dart';
import '../basics/cl_text.dart';
import 'cl_quickmenu.dart';

class CLButtonsGrid extends ConsumerWidget {
  const CLButtonsGrid({
    super.key,
    required this.clMenuItems2D,
  }) : onCancelNullable = null;
  const CLButtonsGrid.dialog({
    super.key,
    required this.clMenuItems2D,
    required Function() onCancel,
  }) : onCancelNullable = onCancel;
  final List<List<CLMenuItem>> clMenuItems2D;
  final Function()? onCancelNullable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final length =
        clMenuItems2D.map((e) => e.length).reduce((a, b) => a > b ? a : b);
    return Center(
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
                      child: CLButtonElevated.large(
                        onTap: clMenuItems1D[i].onTap ??
                            () {
                              showSnackBarAboveDialog(
                                  context, clMenuItems1D[i].title);
                            },
                        child: CLIconLabelled.large(
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
    );
  }

  void showSnackBarAboveDialog(BuildContext context, String message,
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