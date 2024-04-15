import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:open_file/open_file.dart';

import 'process/image_processing.dart';
import 'providers/editor_options.dart';

extension PrintEditActionDetails on EditActionDetails {
  void printAll() {
    /* print(cropAspectRatio);
    print(cropRect);
    print(cropRectPadding);
    print(delta);
    print(flipX);
    print(flipY);
    
    
    print(isHalfPi);
    print(isPi);
    print(isTwoPi);
    print(layerDestinationRect);
    print(layoutTopLeft); */
    print('needCrop:$needCrop');
    print('needFlip:$needFlip');
    print('hasEditAction:$hasEditAction');
    print('hasRotateAngle:$hasRotateAngle');
  }
}

class CLImageEditor extends ConsumerStatefulWidget {
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
  ConsumerState<CLImageEditor> createState() => _CLImageEditorState();
}

class _CLImageEditorState extends ConsumerState<CLImageEditor> {
  EditActionDetails? editActionDetails;
  @override
  Widget build(BuildContext context) {
    final editorOptions = ref.watch(editorOptionsProvider);
    final aspectRatio = editorOptions.aspectRatio.aspectRatio;
    return FullscreenLayout(
      useSafeArea: false,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ExtendedImage.file(
                      extendedImageEditorKey: editorOptions.controller,
                      widget.file,
                      fit: BoxFit.contain,
                      mode: ExtendedImageMode.editor,
                      initEditorConfigHandler: (state) {
                        return EditorConfig(
                          cropAspectRatio: aspectRatio,
                          editActionDetailsIsChanged: (editActionDetails) {
                            editActionDetails?.printAll();
                            setState(() {
                              this.editActionDetails = editActionDetails;
                            });
                          },
                        );
                      },
                      cacheRawData: true,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Center(
                      child: CLButtonIcon.small(
                        MdiIcons.rotateRight,
                        onTap: () {
                          editorOptions.controller?.currentState?.rotate();
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Center(
                      child: CLButtonIcon.small(
                        MdiIcons.rotateLeft,
                        onTap: () {
                          editorOptions.controller?.currentState
                              ?.rotate(right: false);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CropperControls(
              onSave: widget.onSave,
              onDiscard: widget.onDiscard,
            ),
          ],
        ),
      ),
    );
  }
}

class CropperControls extends ConsumerWidget {
  const CropperControls({
    required this.onSave,
    required this.onDiscard,
    super.key,
  });
  final void Function(String outFile, {required bool overwrite}) onSave;
  final void Function() onDiscard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorOptions = ref.watch(editorOptionsProvider);
    final aspectRatio = editorOptions.aspectRatio;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .onBackground
            .withAlpha(128), // Color for the circular container
      ),
      child: Row(
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: CLText.large(
                          'Crop',
                          color: Colors.white,
                        ),
                      ),
                      const Align(
                        child: AspectRatioUpdater(),
                      ),
                      Container(),
                    ].map((e) => Expanded(child: e)).toList(),
                  ),
                ),
                Container(
                  // height: 80,
                  alignment: Alignment.center,

                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        for (final ratio in editorOptions.availableAspectRatio)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 16,
                              top: 4,
                              bottom: 4,
                            ),
                            child: Column(
                              children: [
                                CLButtonText.standard(
                                  ratio.title,
                                  color: aspectRatio.ratio == ratio.ratio
                                      ? Colors.white
                                      : Colors.grey,
                                  onTap: () {
                                    ref
                                        .read(editorOptionsProvider.notifier)
                                        .aspectRatio = ratio.copyWith(
                                      isLandscape: aspectRatio.isLandscape,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 4,
            child: DecoratedBox(decoration: BoxDecoration(color: Colors.white)),
          ),
          SaveImage(
            onSave: onSave,
            onDiscard: onDiscard,
          ),
        ],
      ),
    );
  }
}

class AspectRatioUpdater extends ConsumerWidget {
  const AspectRatioUpdater({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorOptions = ref.watch(editorOptionsProvider);
    final aspectRatio = editorOptions.aspectRatio;
    final isLandscape = aspectRatio.isLandscape;
    return GestureDetector(
      onTap: aspectRatio.hasOrientation
          ? () {
              ref.read(editorOptionsProvider.notifier).isAspectRatioLandscape =
                  !isLandscape;
            }
          : null,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scaleX: isLandscape ? 16 / 9 : 1,
              scaleY: isLandscape ? 1 : 16 / 9,
              child: CLIcon.verySmall(
                Icons.image,
                color: aspectRatio.hasOrientation
                    ? isLandscape
                        ? Theme.of(context).disabledColor
                        : Colors.white
                    : Theme.of(context).disabledColor,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Transform.scale(
              scaleX: !isLandscape ? 16 / 9 : 1,
              scaleY: !isLandscape ? 1 : 16 / 9,
              child: CLIcon.verySmall(
                Icons.image,
                color: aspectRatio.hasOrientation
                    ? !isLandscape
                        ? Theme.of(context).disabledColor
                        : Colors.white
                    : Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SaveImage extends ConsumerWidget {
  const SaveImage({required this.onSave, required this.onDiscard, super.key});
  final void Function(String outFile, {required bool overwrite}) onSave;
  final void Function() onDiscard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorOptions = ref.watch(editorOptionsProvider);
    
    return PopupMenuButton<String>(
      child: CLIcon.standard(
        MdiIcons.check,
        color: Colors.white,
      ),
      onSelected: (String value) async {
        if (value == 'Save' || value == 'Save Copy') {
          final path =
              await ImageProcessing.process(editorOptions: editorOptions);
          if (path != null) {
            onSave(path, overwrite: value == 'Save');
          }
        } else if (value == 'Discard') {
          onDiscard();
        }
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
}
