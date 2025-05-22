import 'package:colan_services/services/media_view_service/on_crop_button.dart';
import 'package:colan_services/services/media_view_service/on_edit_button.dart';
import 'package:colan_services/services/media_view_service/on_move_button.dart';
import 'package:colan_services/services/media_view_service/on_pin_button.dart';
import 'package:colan_services/services/media_view_service/on_share_button.dart';
import 'package:flutter/material.dart';

class BottomBarPageView extends StatelessWidget implements PreferredSizeWidget {
  const BottomBarPageView({required this.iconColor, super.key});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OnEditButton(iconColor: iconColor),
        OnCropButton(iconColor: iconColor),
        OnMoveButton(iconColor: iconColor),
        OnShareButton(iconColor: iconColor),
        OnPinButton(iconColor: iconColor),
      ].map((e) => Expanded(child: e)).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
