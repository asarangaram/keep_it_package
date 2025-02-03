import 'package:flutter/material.dart';

import '../models/camera_mode.dart';

class MenuCameraMode extends StatefulWidget {
  const MenuCameraMode({
    required this.onUpdateMode,
    required this.currMode,
    super.key,
  });

  final CameraMode currMode;
  final void Function(CameraMode type) onUpdateMode;

  @override
  State<MenuCameraMode> createState() => _MenuCameraModeState();
}

class _MenuCameraModeState extends State<MenuCameraMode>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  @override
  void initState() {
    tabController =
        TabController(length: CameraMode.values.length, vsync: this);
    tabController.addListener(() {
      widget.onUpdateMode(CameraMode.values[tabController.index]);
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: TabBar(
          controller: tabController,
          dividerColor: Colors.transparent,
          tabs: [
            for (final type in CameraMode.values)
              Tab(
                child: Text(type.capitalizedName),
              ),
          ],
        ),
      ),
    );
  }
}
