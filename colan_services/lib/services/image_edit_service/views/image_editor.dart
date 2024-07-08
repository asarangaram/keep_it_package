import 'dart:io';
import 'dart:typed_data';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../internal/widgets/editor_finalizer.dart';
import '../models/aspect_ratio.dart' as aratio;
import 'crop_control.dart';

class ImageEditService extends StatefulWidget {
  const ImageEditService({
    required this.file,
    required this.onDone,
    required this.onEditAndSave,
    super.key,
  });
  final File file;

  final Future<void> Function() onDone;
  final Future<void> Function(
    Uint8List imageBytes, {
    required bool overwrite,
    bool? needFlip,
    Rect? cropRect,
    double? rotateAngle,
  }) onEditAndSave;

  @override
  State<ImageEditService> createState() => _ImageEditServiceState();
}

class _ImageEditServiceState extends State<ImageEditService> {
  GlobalKey<ExtendedImageEditorState> controller =
      GlobalKey<ExtendedImageEditorState>();

  double rotateAngle = 0;
  aratio.AspectRatio? aspectRatio;
  bool hasEditAction = false;

  void reset() {
    setState(() {
      aspectRatio = null;
      rotateAngle = 0.0;
      controller.currentState?.reset();
      hasEditAction = false;
    });
  }

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
                    widget.file,
                    controller: controller,
                    rotateAngle: rotateAngle,
                    aspectRatio: aspectRatio?.aspectRatio,
                    editActionDetailsIsChanged: (actions) {
                      setState(() {
                        rotateAngle = actions.rotateAngle;
                        hasEditAction = true;
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
                          MdiIcons.rotateRight,
                          onTap: () {
                            controller.currentState?.rotate();
                          },
                        ),
                        CLButtonIcon.small(
                          MdiIcons.flipHorizontal,
                          onTap: () {
                            controller.currentState?.flip();
                          },
                        ),
                        CLButtonIcon.small(
                          MdiIcons.rotateLeft,
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
              allowCopy: false,
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

                await widget.onEditAndSave(
                  state.rawImageData,
                  cropRect:
                      editActionDetails.needCrop ? state.getCropRect() : null,
                  needFlip: editActionDetails.needFlip,
                  rotateAngle: editActionDetails.hasRotateAngle
                      ? editActionDetails.rotateAngle
                      : null,
                  overwrite: overwrite,
                );
                await widget.onDone();
              },
              onDiscard: ({required done}) async {
                reset();
                if (done) {
                  await widget.onDone();
                }
              },
            ),
          ),
        ],
      ),
    );
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
