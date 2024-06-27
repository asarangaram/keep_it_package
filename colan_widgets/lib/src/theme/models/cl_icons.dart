// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'cl_camera_icons.dart';

class CLIcons {
  final CLCameraIcons camera;

  final IconData popMenuAnchor;
  final IconData popMenuSelectedItem;

  final IconData pagePop;

  CLIcons({
    required this.camera,
    required this.popMenuAnchor,
    required this.popMenuSelectedItem,
    required this.pagePop,
  });
}

class DefaultCLIcons extends CLIcons {
  DefaultCLIcons()
      : super(
          camera: DefaultCLCameraIcons(),
          popMenuAnchor: MdiIcons.dotsVertical,
          popMenuSelectedItem: MdiIcons.checkCircle,
          pagePop: MdiIcons.arrowLeft,
        );
}
