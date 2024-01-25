import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../basics/cl_button.dart';
import '../basics/cl_icon.dart';
import '../models/cl_menu_item.dart';
import '../models/cl_scale_type.dart';
import 'cl_dialog_wrapper.dart';

class CLButtonsGrid extends ConsumerWidget {
  const CLButtonsGrid({
    required this.children2D,
    super.key,
    this.scaleType = CLScaleType.standard,
    this.size,
  })  : onCancelNullable = null,
        isDialog = false;
  const CLButtonsGrid.dialog({
    required this.children2D,
    required void Function() onCancel,
    super.key,
    this.scaleType = CLScaleType.standard,
    this.size,
  })  : onCancelNullable = onCancel,
        isDialog = true;
  final List<List<CLMenuItem>> children2D;
  final void Function()? onCancelNullable;
  final CLScaleType scaleType;
  final bool isDialog;
  final Size? size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hCount =
        children2D.map((e) => e.length).reduce((a, b) => a > b ? a : b);
    final vCount = children2D.length;
    final width = size == null ? null : size!.width * hCount;
    final height = size == null ? null : size!.height * vCount;

    return CLDialogWrapper(
      isDialog: isDialog,
      onCancel: onCancelNullable,
      child: SizedBox(
        height: height,
        width: width,
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final clMenuItems1D in children2D)
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < clMenuItems1D.length; i++)
                        Flexible(
                          child: switch (scaleType) {
                            CLScaleType.veryLarge =>
                              CLButtonSquereElevated.veryLarge,
                            CLScaleType.large => CLButtonSquereElevated.large,
                            CLScaleType.standard =>
                              CLButtonSquereElevated.standard,
                            CLScaleType.small => CLButtonSquereElevated.small,
                            CLScaleType.verySmall =>
                              CLButtonSquereElevated.verySmall,
                            CLScaleType.tiny => CLButtonSquereElevated.tiny,
                          }(
                            onTap: clMenuItems1D[i].onTap,
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
                      for (var i = clMenuItems1D.length; i < hCount; i++)
                        Expanded(child: Container()),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
