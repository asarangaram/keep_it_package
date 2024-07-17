import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pull_down_button/pull_down_button.dart';

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
    /* return GestureDetector(
        onTap: onTap,
        child: child,
      ); */

    return WrapMenu(
      builder: (context, showMenu) {
        return GestureDetector(
          onLongPress: showMenu,
          child: Container(
            decoration: BoxDecoration(border: Border.all()),
            child: child,
          ),
        );
      },
    );
  }
}

@immutable
class WrapMenu extends StatelessWidget {
  const WrapMenu({
    required this.builder,
    super.key,
  });

  final PullDownMenuButtonBuilder builder;

  @override
  Widget build(BuildContext context) => PullDownButton(
        itemBuilder: (context) => [
          PullDownMenuItem(
            title: 'Edit',
            onTap: () {},
            icon: Icons.edit,
          ),
          PullDownMenuItem(
            title: 'Move',
            onTap: () {},
            icon: MdiIcons.imageMove,
          ),
          PullDownMenuItem(
            title: 'Share',
            onTap: () {},
            icon: MdiIcons.share,
          ),
          PullDownMenuItem(
            onTap: () {},
            title: 'Delete',
            isDestructive: true,
            icon: Icons.delete,
          ),
        ],
        animationBuilder: null,
        position: PullDownMenuPosition.over,
        buttonBuilder: builder,
      );
}
