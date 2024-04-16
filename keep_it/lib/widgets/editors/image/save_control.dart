import 'package:colan_widgets/colan_widgets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';

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
    /* if (editActionDetails != null) {
      print('hasEditAction: ${editActionDetails!.hasEditAction}');
      print('hasRotateAngle: ${editActionDetails!.hasRotateAngle}');
      print('needCrop: ${editActionDetails!.needCrop}');
      print('needFlip: ${editActionDetails!.needFlip}');
    } */

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

    var image = img.decodeImage(state.rawImageData);
    if (image == null) return null;

    final cropRect = state.getCropRect();
    if (editActionDetails.needCrop &&
        cropRect != null &&
        !cropRect.isSameAs(
          Rect.fromLTRB(
            0,
            0,
            image.width.ceilToDouble(),
            image.height.ceilToDouble(),
          ),
        )) {
      image = img.copyCrop(
        image,
        x: cropRect.left.ceil(),
        y: cropRect.top.ceil(),
        width: (cropRect.right - cropRect.left).ceil(),
        height: (cropRect.bottom - cropRect.top).ceil(),
      );
    }
    if (editActionDetails.needFlip) {
      image = img.flipHorizontal(image);
    }
    if (editActionDetails.hasRotateAngle) {
      image = img.copyRotate(image, angle: editActionDetails.rotateAngle);
    }
    return saveFile(image);
  }

  static Future<String?> saveFile(img.Image? image) async {
    if (image == null) return null;
    final cacheDir = await getTemporaryDirectory();

    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final imageFile = '${cacheDir.path}/$fileName';

    await img.encodeJpgFile(imageFile, image);

    return imageFile;
  }
}

extension IntCompareRect on Rect {
  bool isSameAs(Rect other) {
    return left.ceil() == other.left.ceil() &&
        right.ceil() == other.right.ceil() &&
        top.ceil() == other.top.ceil() &&
        bottom.ceil() == other.bottom.ceil();
  }
}
