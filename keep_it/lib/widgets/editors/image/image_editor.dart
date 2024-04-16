import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'crop_control.dart';
import 'models/aspect_ratio.dart' as aratio;
import 'save_control.dart';

class CLImageEditor extends StatefulWidget {
  const CLImageEditor({
    required this.file,
    required this.onSave,
    required this.onDiscard,
    super.key,
  });
  final File file;
  final void Function(String outFile, {required bool overwrite}) onSave;
  final void Function() onDiscard;

  @override
  State<CLImageEditor> createState() => _CLImageEditorState();
}

class _CLImageEditorState extends State<CLImageEditor> {
  GlobalKey<ExtendedImageEditorState> controller =
      GlobalKey<ExtendedImageEditorState>();

  double rotateAngle = 0;
  aratio.AspectRatio? aspectRatio;

  void reset() {
    setState(() {
      aspectRatio = null;
      rotateAngle = 0.0;
      controller.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FullscreenLayout(
      useSafeArea: false,
      hasBackground: false,
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      child: SafeArea(
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
                        });

                        /* print('edit action: ${actions.hasEditAction}');
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
              saveWidget: SaveImage(
                controller: controller,
                onSave: widget.onSave,
                onDiscard: ({required bool done}) {
                  reset();
                  if (done) {
                    widget.onDiscard();
                  }
                },
              ),
            ),
          ],
        ),
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
