import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../../modules/shared_media/cl_media_process.dart';

class SaveImage extends ConsumerWidget {
  const SaveImage({
    required this.controller,
    required this.onSave,
    required this.onDiscard,
    super.key,
  });
  final GlobalKey<ExtendedImageEditorState> controller;
  final void Function(String outFile, {required bool overwrite}) onSave;
  final void Function() onDiscard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      child: CLIcon.standard(
        MdiIcons.check,
        color: Colors.white,
      ),
      onSelected: (String value) async {
        if (value == 'Save' || value == 'Save Copy') {
          final path = await process();
          if (path != null) {
            onSave(path, overwrite: value == 'Save');
          }
        } else if (value == 'Discard') {}
      },
      itemBuilder: (BuildContext context) {
        return {'Save', 'Save Copy', 'Discard'}.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
    );
  }

  Future<String?> process() async {
    if (controller.currentState == null) {
      return null;
    }
    final state = controller.currentState!;
    final editActionDetails = state.editAction;

    if (editActionDetails == null) {
      return null;
    }

    final cacheDir = await getTemporaryDirectory();
    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final imageFile = '${cacheDir.path}/$fileName';

    File(imageFile).createSync(recursive: true);

    await ExtProcess.imageCropper(
      state.rawImageData,
      cropRect: editActionDetails.needCrop ? state.getCropRect() : null,
      needFlip: editActionDetails.needFlip,
      rotateAngle: editActionDetails.hasRotateAngle
          ? editActionDetails.rotateAngle
          : null,
      outFile: imageFile,
    );
    return imageFile;
  }
}
