import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'providers/editor_options.dart';

class CLImageEditor extends ConsumerStatefulWidget {
  const CLImageEditor({required this.file, super.key});
  final File file;

  @override
  ConsumerState<CLImageEditor> createState() => _CLImageEditorState();
}

class _CLImageEditorState extends ConsumerState<CLImageEditor> {
  final GlobalKey<ExtendedImageEditorState> _controller =
      GlobalKey<ExtendedImageEditorState>();
  int rotateAngle = 0;

  @override
  void initState() {
    _controller.currentState?.rotate();
    super.initState();
  }

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
                      extendedImageEditorKey: _controller,
                      widget.file,
                      fit: BoxFit.contain,
                      mode: ExtendedImageMode.editor,
                      initEditorConfigHandler: (state) {
                        return EditorConfig(
                          cropAspectRatio: aspectRatio,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Center(
                      child: CLButtonIcon.small(
                        MdiIcons.rotateRight,
                        onTap: () {
                          _controller.currentState?.rotate();
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
                          _controller.currentState?.rotate(right: false);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const CropperControls(),
          ],
        ),
      ),
    );
  }
}

class CropperControls extends ConsumerWidget {
  const CropperControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorOptions = ref.watch(editorOptionsProvider);
    final aspectRatio = editorOptions.aspectRatio;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .onBackground
            .withAlpha(128), // Color for the circular container
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  for (final ratio in editorOptions.availableAspectRatio)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
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
                          if (aspectRatio.ratio == ratio.ratio &&
                              aspectRatio.hasOrientation)
                            const SizedBox(
                              height: 40,
                              child: AspectRatioUpdater(),
                            )
                          else
                            const SizedBox(
                              height: 40,
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
    return Transform.scale(
      scaleX: isLandscape ? 16 / 9 : 1,
      scaleY: isLandscape ? 1 : 16 / 9,
      child: CLButtonIcon.verySmall(
        Icons.image,
        color: Colors.white,
        onTap: () {
          ref.read(editorOptionsProvider.notifier).isAspectRatioLandscape =
              !isLandscape;
        },
      ),
    );
  }
}
