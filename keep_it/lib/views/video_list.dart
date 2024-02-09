// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoList extends ConsumerStatefulWidget {
  const VideoList({required this.media, super.key});
  final List<CLMedia> media;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideoListState();
}

class _VideoListState extends ConsumerState<VideoList> {
  late final AutoScrollController controller;
  int? currentIndex;

  @override
  void initState() {
    controller = AutoScrollController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentIndex != null) {
        controller.scrollToIndex(
          currentIndex!,
          preferPosition: AutoScrollPosition.begin,
        );
      }
    });
    return CLCustomGrid(
      itemCount: widget.media.length,
      crossAxisCount: 1,
      layers: 1,
      controller: controller,
      itemBuilder: (context, index, l) {
        return VideoViewer(
          media: widget.media[index],
          onSelect: () async {
            setState(() {
              currentIndex = index;
            });
          },
        );
      },
    );
  }
}

class VideoViewer extends ConsumerWidget {
  const VideoViewer({required this.media, super.key, this.onSelect});
  final CLMedia media;
  final void Function()? onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(videoPlayerProvider);
    Future<void> onTap() async {
      await ref.read(videoPlayerProvider.notifier).playVideo(media.path);
      onSelect?.call();
    }

    if (state.path != media.path) {
      return VideoPreview(media: media, onTap: onTap);
    }

    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        if (state.path == media.path)
          state.controllerAsync.when(
            data: (controller) => Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * .65,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VisibilityDetector(
                    key: ValueKey(controller),
                    onVisibilityChanged: (info) {
                      if (context.mounted) {
                        if (info.visibleFraction == 0.0) {
                          if (state.path == media.path) {
                            ref
                                .read(videoPlayerProvider.notifier)
                                .stopVideo(media.path);
                          }
                        }
                      }
                    },
                    child: CLVideoPlayer(
                      controller: controller,
                    ),
                  ),
                ),
              ),
            ),
            error: (_, __) => Container(),
            loading: () => VideoPreview(
              media: media,
              onTap: onTap,
              overlayChild: const CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

class VideoPreview extends ConsumerWidget {
  const VideoPreview({
    required this.media,
    super.key,
    this.onTap,
    this.overlayChild,
  });
  final CLMedia media;
  final void Function()? onTap;
  final Widget? overlayChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(thumbnailProvider(media)).when(
          data: (thumbnail) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * .65,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
              child: GestureDetector(
                onTap: onTap,
                child: Image.file(
                  thumbnail,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) => Stack(
                    alignment: AlignmentDirectional.topCenter,
                    children: [
                      child,
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
                  fit: BoxFit.scaleDown,
                  filterQuality: FilterQuality.none,
                ),
              ),
            ),
          ),
          error: (error, stackTrace) => Container(),
          loading: Container.new,
        );
  }
}

final thumbnailProvider =
    FutureProvider.family<File, CLMedia>((ref, media) async {
  {
    if (!File(media.path).existsSync()) {
      throw FileSystemException('missing', media.path);
    }
    if (media.previewPath != null) {
      final preview = File(media.previewPath!);
      if (preview.existsSync()) {
        return preview;
      }
    }
    {
      final preview = File(media.previewFileName);
      if (preview.existsSync()) {
        return preview;
      }
    }
  }
  // Now its clearn we don't have preview already generated.
  // Lets try generating. For now, we support only Video thumbnail
  if (media.type != CLMediaType.video) {
    throw Exception('thumbnail not found');
  }

  final thumbnailPath = await VideoThumbnail.thumbnailFile(
    video: media.path,
    imageFormat: ImageFormat.JPEG,
    quality: 25,
  );
  if (thumbnailPath == null) {
    throw Exception('Unable to generate thumbnail');
  }
  return File(thumbnailPath);
});

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

@immutable
class VideoPlayState {
  final String? path;
  final AsyncValue<VideoPlayerController> controllerAsync;
  const VideoPlayState({
    this.path,
    this.controllerAsync = const AsyncValue.loading(),
  });

  @override
  bool operator ==(covariant VideoPlayState other) {
    if (identical(this, other)) return true;

    return other.path == path && other.controllerAsync == controllerAsync;
  }

  @override
  int get hashCode => path.hashCode ^ controllerAsync.hashCode;

  VideoPlayState copyWith({
    String? path,
    AsyncValue<VideoPlayerController>? controllerAsync,
  }) {
    return VideoPlayState(
      path: path ?? this.path,
      controllerAsync: controllerAsync ?? this.controllerAsync,
    );
  }
}

class VideoPlayerNotifier extends StateNotifier<VideoPlayState> {
  VideoPlayerController? controller;
  VideoPlayerNotifier() : super(const VideoPlayState());

  Future<void> playVideo(String path) async {
    state = VideoPlayState(path: path);
    try {
      if (!File(path).existsSync()) {
        throw FileSystemException('missing file', path);
      }
      if (controller != null) {
        await controller!.pause();
        await controller!.dispose();
      }
      controller = VideoPlayerController.file(File(path));
      if (controller == null) {
        throw Exception('Failed to create controller');
      }
      final newController = controller!;
      await newController.initialize();
      if (!newController.value.isInitialized) {
        throw Exception('Failed to load Video');
      }
      await newController.setVolume(0.1);
      await newController.seekTo(Duration.zero);
      await newController.play();
      state = state.copyWith(controllerAsync: AsyncValue.data(newController));
    } catch (error, stackTrace) {
      state = state.copyWith(controllerAsync: AsyncError(error, stackTrace));
    }
  }

  Future<void> stopVideo(String? path) async {
    if (path == state.path || path == null) {
      if (controller != null) {
        await controller!.pause();
        state = const VideoPlayState();
        await controller!.dispose();
        controller = null;
      }
    }
  }

  @override
  void dispose() {
    if (mounted) {
      if (controller?.value.isPlaying ?? false) {
        controller?.pause();
      }
      controller?.dispose();
      super.dispose();
    }
  }
}

final videoPlayerProvider =
    StateNotifierProvider.autoDispose<VideoPlayerNotifier, VideoPlayState>(
        (ref) {
  final notifier = VideoPlayerNotifier();
  return notifier;
});
