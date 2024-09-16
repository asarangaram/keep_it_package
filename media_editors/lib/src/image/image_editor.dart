import 'dart:io';
import 'dart:typed_data';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../editor_finalizer.dart';
import 'models/aspect_ratio.dart' as aratio;
import 'models/image_processing.dart';
import 'views/crop_control.dart';

class ImageEditor extends StatefulWidget {
  const ImageEditor({
    required this.uri,
    required this.onCancel,
    required this.onCreateNewFile,
    required this.onSave,
    required this.canDuplicateMedia,
    super.key,
  });
  final Uri uri;
  final bool canDuplicateMedia;
  final Future<void> Function() onCancel;

  final Future<String> Function() onCreateNewFile;
  final Future<void> Function(String, {required bool overwrite}) onSave;
  @override
  State<ImageEditor> createState() => _ImageEditorState();
}

class _ImageEditorState extends State<ImageEditor> {
  GlobalKey<ExtendedImageEditorState> controller =
      GlobalKey<ExtendedImageEditorState>();

  double rotateAngle = 0;
  aratio.AspectRatio? aspectRatio;
  bool editActionDetailsIsChanged = false;

  void reset() {
    setState(() {
      aspectRatio = null;
      rotateAngle = 0.0;
      controller.currentState?.reset();
      editActionDetailsIsChanged = false;
    });
  }

  bool get hasEditAction => editActionDetailsIsChanged || (aspectRatio != null);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: EditableImageView(
                    key: ValueKey(aspectRatio),
                    File(widget.uri.toFilePath()),
                    controller: controller,
                    rotateAngle: rotateAngle,
                    aspectRatio: aspectRatio?.aspectRatio,
                    editActionDetailsIsChanged: (actions) {
                      setState(() {
                        rotateAngle = actions.rotateAngle;
                        editActionDetailsIsChanged = true;
                      });

                      /* 
                      if (actions.hasEditAction) {
                        if (actions.hasRotateAngle) {
                          setState(() {
                            rotationAngle = actions.rotateAngle;
                          });
                        }
                        if (actions.needCrop) {}
                      } else {
                        setState(() {
                          rotationAngle = 0;
                        });
                      } */
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CLButtonIcon.small(
                          clIcons.imageEditRotateRight,
                          onTap: () {
                            controller.currentState?.rotate();
                          },
                        ),
                        CLButtonIcon.small(
                          clIcons.imageEditFlipHirizontal,
                          onTap: () {
                            controller.currentState?.flip();
                          },
                        ),
                        CLButtonIcon.small(
                          clIcons.imageEditRotateLeft,
                          onTap: () {
                            controller.currentState?.rotate(right: false);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          CropperControls(
            aspectRatio: aspectRatio,
            rotateAngle: rotateAngle,
            onChangeAspectRatio: (aspectRatio) {
              setState(() {
                this.aspectRatio = aspectRatio;
              });
            },
            saveWidget: EditorFinalizer(
              canDuplicateMedia: widget.canDuplicateMedia,
              hasEditAction: hasEditAction,
              onSave: ({required overwrite}) async {
                if (controller.currentState == null) {
                  return;
                }
                final state = controller.currentState!;
                final editActionDetails = state.editAction;

                if (editActionDetails == null) {
                  return;
                }

                await editAndSave(
                  state.rawImageData,
                  cropRect:
                      editActionDetails.needCrop ? state.getCropRect() : null,
                  needFlip: editActionDetails.needFlip,
                  rotateAngle: editActionDetails.hasRotateAngle
                      ? editActionDetails.rotateAngle
                      : null,
                  overwrite: overwrite,
                  onSave: widget.onSave,
                );
              },
              onDiscard: ({required done}) async {
                reset();
                if (done) {
                  await widget.onCancel();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> editAndSave(
    Uint8List imageBytes, {
    required bool overwrite,
    required Rect? cropRect,
    required bool? needFlip,
    required double? rotateAngle,
    required Future<void> Function(String, {required bool overwrite}) onSave,
  }) async {
    final fileName = await widget.onCreateNewFile();

    await ImageProcessing.imageCropper(
      imageBytes,
      cropRect: cropRect,
      needFlip: needFlip ?? false,
      rotateAngle: rotateAngle,
      outFile: fileName,
    );

    await onSave(fileName, overwrite: overwrite);
  }
}

class EditableImageView extends ConsumerStatefulWidget {
  const EditableImageView(
    this.file, {
    required this.controller,
    required this.editActionDetailsIsChanged,
    super.key,
    this.aspectRatio,
    this.rotateAngle = 0,
  });
  final File file;
  final GlobalKey<ExtendedImageEditorState> controller;
  final double? aspectRatio;
  final double rotateAngle;
  final void Function(EditActionDetails) editActionDetailsIsChanged;

  @override
  ConsumerState<EditableImageView> createState() => _EditableImageViewState();
}

class _EditableImageViewState extends ConsumerState<EditableImageView> {
  void restoreState() {
    if (widget.controller.currentState?.editAction?.rotateAngle !=
        widget.rotateAngle) {
      for (var i = 0; i < (widget.rotateAngle / 90); i++) {
        widget.controller.currentState?.rotate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      restoreState();
    });
    return ExtendedImage.file(
      extendedImageEditorKey: widget.controller,
      widget.file,
      fit: BoxFit.contain,
      mode: ExtendedImageMode.editor,
      cacheRawData: true,
      initEditorConfigHandler: (state) {
        return EditorConfig(
          cropAspectRatio: widget.aspectRatio,
          editActionDetailsIsChanged: (editActionDetails) {
            if (editActionDetails == null) return;
            widget.editActionDetailsIsChanged(editActionDetails);
          },
        );
      },
    );
  }
}
