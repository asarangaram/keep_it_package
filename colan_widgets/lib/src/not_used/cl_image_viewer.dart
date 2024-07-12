import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../basics/cl_scrollable.dart';
import '../views/appearance/cl_error_view.dart';
import '../views/appearance/cl_loading_view.dart';

class ImageViewer extends ConsumerWidget {
  const ImageViewer({required this.path, super.key});
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(imageProvider(path));
    return image.when(
      data: (image) {
        return CLImageViewer(image: image);
      },
      error: (e, st) => CLErrorView(errorMessage: e.toString()),
      loading: CLLoadingView.new,
    );
  }
}

final imageProvider =
    FutureProvider.family<ui.Image, String>((ref, path) async {
  final bytes = await File(path).readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final frameInfo = await codec.getNextFrame();
  return frameInfo.image;
});

/// If OnTap is provided, onZoom is assigned to onDoubleTap
class CLImageViewer extends StatefulWidget {
  const CLImageViewer({
    required this.image,
    super.key,
    this.allowZoom = true,
    this.isFullScreen = false,
    this.onTap,
    this.overlayWidget,
  });
  final ui.Image image;
  final bool allowZoom;
  final bool isFullScreen;
  final void Function()? onTap;
  final Widget? overlayWidget;

  @override
  State<CLImageViewer> createState() => _CLImageViewerState();
}

class _CLImageViewerState extends State<CLImageViewer> {
  late bool fullscreen;
  late void Function()? onTap;
  late void Function()? onDoubleTap;
  late void Function()? onZoom;

  @override
  void initState() {
    fullscreen = widget.isFullScreen;

    onZoom = widget.allowZoom
        ? () => setState(() {
              fullscreen = !fullscreen;
            })
        : null;
    onTap = widget.onTap ?? onZoom;
    onDoubleTap = widget.onTap != null ? onZoom : null;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (fullscreen) {
            return CLScrollable(
              childHeight: widget.image.height.toDouble(),
              childWidth: widget.image.width.toDouble(),
              child: RawImage(
                image: widget.image,
              ),
            );
          } else {
            return Stack(
              children: [
                Center(
                  child: RawImage(
                    image: widget.image,
                  ),
                ),
                if (widget.overlayWidget != null)
                  Positioned.fill(
                    child: Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.4,
                        heightFactor: 0.4,
                        child: FittedBox(child: widget.overlayWidget),
                      ),
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }
}
