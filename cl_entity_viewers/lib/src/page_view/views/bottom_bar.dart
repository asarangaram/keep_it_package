import 'package:flutter/material.dart';

import 'on_crop_button.dart';
import 'on_edit_button.dart';
import 'on_move_button.dart';
import 'on_pin_button.dart';
import 'on_share_button.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({required this.iconColor, super.key});

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
}
