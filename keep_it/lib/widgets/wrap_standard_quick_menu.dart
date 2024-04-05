import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class WrapStandardQuickMenu extends StatelessWidget {
  const WrapStandardQuickMenu({
    required this.quickMenuScopeKey,
    required this.child,
    super.key,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.onMove,
    this.onShare,
  });
  final Widget child;

  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  final Future<bool?> Function()? onEdit;
  final Future<bool?> Function()? onDelete;
  final Future<bool?> Function()? onMove;
  final Future<bool?> Function()? onShare;
  final Future<bool?> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    if (onEdit == null && onDelete == null) {
      return GestureDetector(
        onTap: onTap,
        child: child,
      );
    }
    return CLQuickMenuAnchor.longPress(
      parentKey: quickMenuScopeKey,
      menuBuilder: (
        context,
        boxconstraints, {
        required void Function() onDone,
      }) {
        return CLButtonsGrid(
          scaleType: CLScaleType.veryLarge,
          size: const Size(
            kMinInteractiveDimension * 1.5,
            kMinInteractiveDimension * 1.5,
          ),
          children2D: [
            [
              if (onEdit != null)
                CLMenuItem(
                  title: 'Edit',
                  icon: Icons.edit_rounded,
                  onTap: onEdit,
                ),
              if (onDelete != null)
                CLMenuItem(
                  title: 'Delete',
                  icon: Icons.delete_rounded,
                  onTap: onDelete,
                ),
              if (onMove != null)
                CLMenuItem(
                  title: 'Move',
                  icon: MdiIcons.imageMove,
                  onTap: onMove,
                ),
              if (onShare != null)
                CLMenuItem(
                  title: 'Share',
                  icon: MdiIcons.share,
                  onTap: () async {
                    return onShare!();
                  },
                ),
            ]
          ].insertOnDone(onDone),
        );
      },
      onTap: onTap,
      child: child,
    );
  }
}
