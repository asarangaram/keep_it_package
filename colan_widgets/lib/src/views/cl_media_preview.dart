import 'dart:io';

import 'package:colan_widgets/src/models/cl_media/extensions/url_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import '../basics/cl_icon.dart';
import '../models/cl_media.dart';
import '../video_player/providers/thumbnail.dart';

class CLMediaPreview extends StatelessWidget {
  const CLMediaPreview({
    required this.media,
    this.keepAspectRatio = true,
    super.key,
  });
  final CLMedia media;
  final bool keepAspectRatio;
  @override
  Widget build(BuildContext context) {
    if (media.type.isFile && !File(media.path).existsSync()) {
      throw Exception('File not found ${media.path}');
    }
    final fit = keepAspectRatio ? BoxFit.contain : BoxFit.cover;
    return KeepAspectRatio(
      keepAspectRatio: keepAspectRatio,
      child: switch (media.type) {
        CLMediaType.image => Image.file(
            File(media.previewPath!),
            fit: fit,
          ),
        CLMediaType.video => VideoPreview(media: media, fit: fit),
        CLMediaType.url => FutureBuilder(
            future: URLHandler.getMimeType(media.path),
            builder: (context, snapShot) {
              if (snapShot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return switch (snapShot.data) {
                (final mimeType) when mimeType == CLMediaType.image =>
                  Image.network(
                    media.path,
                    fit: fit,
                  ),
                (final mimeType) when mimeType == CLMediaType.video =>
                  VideoPreview(
                    media: CLMedia(path: media.path, type: CLMediaType.video),
                    fit: fit,
                  ),
                _ => MediaPlaceHolder(media: media)
              };
            },
          ),
        _ => MediaPlaceHolder(media: media)
      },
    );
  }
}

class KeepAspectRatio extends StatelessWidget {
  const KeepAspectRatio({
    required this.child,
    super.key,
    this.keepAspectRatio = true,
  });
  final bool keepAspectRatio;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (keepAspectRatio) return child;
    return AspectRatio(
      aspectRatio: 1,
      child: child,
    );
  }
}

class MediaPlaceHolder extends StatelessWidget {
  const MediaPlaceHolder({
    required this.media,
    super.key,
  });

  final CLMedia media;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox.square(
          dimension: 60 + 16,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Center(
                child: Text(
                  path.basename(media.path),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VideoPreview extends ConsumerWidget {
  const VideoPreview({
    required this.media,
    super.key,
    this.onTap,
    this.overlayChild,
    this.fit,
  });
  final CLMedia media;
  final void Function()? onTap;
  final Widget? overlayChild;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(thumbnailProvider(media)).when(
          data: (thumbnail) => GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.file(
                    thumbnail,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.none,
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.2,
                      heightFactor: 0.2,
                      child: FittedBox(
                        child: overlayChild ?? const VidoePlayIcon(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          error: (error, stackTrace) => MediaPlaceHolder(
            media: media,
          ),
          loading: () => SizedBox.expand(
            child: ColoredBox(
              color: Theme.of(context).colorScheme.inverseSurface,
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
            ),
          ),
        );
  }
}

class VidoePlayIcon extends StatelessWidget {
  const VidoePlayIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context)
            .colorScheme
            .onBackground
            .withAlpha(192), // Color for the circular container
      ),
      child: CLIcon.veryLarge(
        Icons.play_arrow_sharp,
        color: Theme.of(context).colorScheme.background.withAlpha(192),
      ),
    );
  }
}

const _shimmerGradient = LinearGradient(
  colors: [
    Color(0xFFEBEBF4),
    Color(0xFFF4F4F4),
    Color(0xFFEBEBF4),
  ],
  stops: [
    0.1,
    0.3,
    0.4,
  ],
  begin: Alignment(-1, -0.3),
  end: Alignment(1, 0.3),
);

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> {
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: _shimmerGradient.createShader,
    );
  }
}
