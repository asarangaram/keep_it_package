import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/editor_options.dart';

class CLImageEditor extends ConsumerStatefulWidget {
  const CLImageEditor({required this.file, super.key});
  final File file;

  @override
  ConsumerState<CLImageEditor> createState() => _CLImageEditorState();
}

class _CLImageEditorState extends ConsumerState<CLImageEditor> {
  bool isLandscape = false;

  @override
  Widget build(BuildContext context) {
    final editorOptions = ref.watch(editorOptionsProvider);
    final aspectRatio = editorOptions.aspectRatio?.ratio == null
        ? null
        : editorOptions.isAspectRatioLandscape
            ? editorOptions.aspectRatio?.ratio!
            : (1 / (editorOptions.aspectRatio?.ratio)!);
    return Column(
      children: [
        Expanded(
          child: ExtendedImage.file(
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
        const CropperControls(),
      ],
    );
  }
}

class CropperControls extends ConsumerWidget {
  const CropperControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorOptions = ref.watch(editorOptionsProvider);
    final aspectRatio = editorOptions.aspectRatio?.ratio == null
        ? null
        : editorOptions.isAspectRatioLandscape
            ? editorOptions.aspectRatio?.ratio!
            : (1 / (editorOptions.aspectRatio?.ratio)!);

    final isLandscape = editorOptions.isAspectRatioLandscape;
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .onBackground
            .withAlpha(192), // Color for the circular container
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (aspectRatio != null && aspectRatio != 1)
                    IconButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      icon: Icon(
                        Icons.portrait,
                        color: isLandscape ? Colors.white : Colors.grey,
                      ),
                      onPressed: () {
                        ref
                            .read(editorOptionsProvider.notifier)
                            .isAspectRatioLandscape = !isLandscape;
                      },
                    ),
                  for (final ratio in editorOptions.availableAspectRatio)
                    TextButton(
                      onPressed: () {
                        ref.read(editorOptionsProvider.notifier).aspectRatio =
                            ratio;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          ratio.title,
                          style: TextStyle(
                            color: aspectRatio == ratio.ratio
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
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
