import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import '../../models/content_origin.dart';

@immutable
class WizardMenuItems {
  const WizardMenuItems({
    required this.type,
    required this.option1,
    required this.option2,
  });

  factory WizardMenuItems.moveOrCancel({
    required ContentOrigin type,
    String? keepActionLabel,
    String? deleteActionLabel,
    Future<bool> Function()? keepAction,
    Future<bool> Function()? deleteAction,
  }) {
    return WizardMenuItems(
      type: type,
      option1: CLMenuItem(
        icon: clIcons.save,
        title: keepActionLabel ?? type.keepActionLabel,
        onTap: keepAction == null ? null : () => keepAction(),
      ),
      option2: CLMenuItem(
        icon: clIcons.deleteItem,
        title: deleteActionLabel ?? type.deleteActionLabel,
        onTap: deleteAction == null ? null : () => deleteAction(),
      ),
    );
  }

  final ContentOrigin type;
  final CLMenuItem option1;
  final CLMenuItem option2;
}
