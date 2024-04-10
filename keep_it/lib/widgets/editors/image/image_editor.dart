import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:extended_image/extended_image.dart';
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
                          ref
                              .read(editorOptionsProvider.notifier)
                              .rotateRight();
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
                          ref.read(editorOptionsProvider.notifier).rotateLeft();
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
          const SaveImage(),
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
        color: aspectRatio.hasOrientation
            ? Colors.white
            : Theme.of(context).disabledColor,
        onTap: aspectRatio.hasOrientation
            ? () {
                ref
                    .read(editorOptionsProvider.notifier)
                    .isAspectRatioLandscape = !isLandscape;
              }
            : null,
      ),
    );
  }
}

class SaveImage extends ConsumerWidget {
  const SaveImage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorOptions = ref.watch(editorOptionsProvider);

    if (!editorOptions.hasData) {
      return CLButtonIcon.standard(
        MdiIcons.close,
        color: Colors.white,
        onTap: () {},
      );
    }
    return PopupMenuButton<String>(
      child: CLIcon.standard(
        MdiIcons.check,
        color: Colors.white,
      ),
      onSelected: (String value) {
        if (value == 'Save') {
        } else if (value == 'Save Copy') {
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
}
