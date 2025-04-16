import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import '../widgets/actions_draggable_menu.dart';

import 'viewer_entity_mixin.dart';

typedef DraggableMenuBuilderType = Widget Function(
  BuildContext, {
  required GlobalKey<State<StatefulWidget>> parentKey,
});

@immutable
abstract class CLContextMenu {
  const CLContextMenu();

  List<CLMenuItem> get actions;

  DraggableMenuBuilderType? draggableMenuBuilder(
    BuildContext context,
    void Function() onDone,
  ) {
    if (actions.isNotEmpty) {
      return (context, {required parentKey}) {
        return ActionsDraggableMenu<ViewerEntityMixin>(
          parentKey: parentKey,
          tagPrefix: 'Selection',
          menuItems: actions.insertOnDone(onDone),
        );
      };
    }

    return null;
  }
}
