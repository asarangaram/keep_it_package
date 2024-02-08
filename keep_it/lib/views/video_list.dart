import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoList extends ConsumerStatefulWidget {
  const VideoList({required this.media, super.key});
  final List<CLMedia> media;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideoListState();
}

class _VideoListState extends ConsumerState<VideoList> {
  late final AutoScrollController controller;
  final int currentIndex = 0;
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
    return CLCustomGrid(
      itemCount: widget.media.length,
      crossAxisCount: 1,
      layers: 1,
      controller: controller,
      itemBuilder: (context, index, l) {
        return VideoPreview(
          media: widget.media[index],
        );
      },
    );
  }
}

class VideoPreview extends ConsumerWidget {
  const VideoPreview({required this.media, super.key});
  final CLMedia media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(thumbnailProvider(media)).when(
          data: (thumbnail) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * .65,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
              child: Image.file(
                thumbnail,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
                    Stack(
                  alignment: AlignmentDirectional.topCenter,
                  children: [
                    child,
                    const Center(
                      child: FractionallySizedBox(
                        widthFactor: 1,
                        heightFactor: 1,
                        child: CLIcon.large(Icons.play_circle),
                      ),
                    ),
                  ],
                ),
                fit: BoxFit.scaleDown,
                filterQuality: FilterQuality.none,
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
  if (false) {
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
