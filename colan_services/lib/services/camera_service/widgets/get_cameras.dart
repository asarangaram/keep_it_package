import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../providers/camera_provider.dart';

class GetCameras extends ConsumerStatefulWidget {
  const GetCameras({required this.builder, super.key});
  final Widget Function({
    required CameraDescription frontCamera,
    required CameraDescription backCamera,
    required Widget cameraSelector,
  }) builder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GetCamerasState();
}

class _GetCamerasState extends ConsumerState<GetCameras> {
  @override
  Widget build(BuildContext context) {
    // TODO(anandas): Read these values from settings
    const defaultFrontCameraIndex = 0;
    const defaultBackCameraIndex = 0;
    final camerasAsync = ref.watch(camerasProvider);
    return camerasAsync.when(
      data: (cameras) {
        return widget.builder(
          frontCamera: cameras
              .where(
                (e) => e.lensDirection == CameraLensDirection.front,
              )
              .toList()[defaultFrontCameraIndex],
          backCamera: cameras
              .where(
                (e) => e.lensDirection == CameraLensDirection.back,
              )
              .toList()[defaultBackCameraIndex],
          cameraSelector: cameraSelector(cameras),
        );
      },
      error: (e, st) => CLErrorView(errorMessage: e.toString()),
      loading: CLLoadingView.new,
    );
  }

  Widget cameraSelector(List<CameraDescription> cameras) {
    final backCameras = cameras
        .where(
          (e) => e.lensDirection == CameraLensDirection.back,
        )
        .toList();
    final numberOfBackCameras = backCameras.length;
    final numberOfFrontCameras = cameras
        .where(
          (e) => e.lensDirection == CameraLensDirection.front,
        )
        .length;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: NumberDropdown(
                  n: numberOfFrontCameras,
                  label: 'Front Camera',
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              Expanded(
                child: NumberDropdown(
                  n: numberOfBackCameras,
                  label: 'Back Camera',
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              const CLButtonIconLabelled.small(Icons.volume_mute, 'audio'),
              const SizedBox(
                width: 4,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NumberDropdown extends StatefulWidget {
  const NumberDropdown({required this.n, required this.label, super.key});
  final int n;
  final String label;

  @override
  NumberDropdownState createState() => NumberDropdownState();
}

class NumberDropdownState extends State<NumberDropdown> {
  int selectedNumber = 0;

  @override
  Widget build(BuildContext context) {
    final numberList = List<int>.generate(widget.n, (i) => i);

    return DropdownMenu<int>(
      initialSelection: selectedNumber,
      label: Text(widget.label),
      // hint: const Text('Select Camera'),
      onSelected: (int? newValue) {
        if (newValue != null) {
          setState(() {
            selectedNumber = newValue;
          });
        }
      },
      expandedInsets: EdgeInsets.zero,
      dropdownMenuEntries: numberList.map<DropdownMenuEntry<int>>((int value) {
        return DropdownMenuEntry<int>(
          value: value,
          label: value.toString(),
        );
      }).toList(),
    );
  }
}
