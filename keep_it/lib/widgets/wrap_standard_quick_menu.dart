import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class WrapStandardQuickMenu extends StatelessWidget {
  const WrapStandardQuickMenu({
    required this.quickMenuScopeKey,
    required this.child,
    super.key,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });
  final Widget child;

  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  final Future<bool?> Function()? onEdit;
  final Future<bool?> Function()? onDelete;
  final Future<bool?> Function()? onTap;

  @override
  Widget build(BuildContext context) {
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
              CLMenuItem(
                title: 'Edit',
                icon: Icons.edit,
                onTap: onEdit,
              ),
              CLMenuItem(
                title: 'Delete',
                icon: Icons.delete,
                onTap: onDelete,
              ),
            ]
          ].insertOnDone(onDone),
        );
      },
      onTap: () => onTap,
      child: child,
    );
  }
}
