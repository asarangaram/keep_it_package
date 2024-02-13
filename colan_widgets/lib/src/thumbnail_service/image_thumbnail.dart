import 'dart:io';

import 'package:colan_widgets/src/media_preview/broken_image.dart';
import 'package:colan_widgets/src/thumbnail_service/io_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cl_media.dart';
import 'thumbnail_services.dart';

class ImageThumbnail extends ConsumerStatefulWidget {
  const ImageThumbnail({
    required this.media,
    required this.builder,
    super.key,
    this.refresh = false,
  });
  final CLMedia media;
  final bool refresh;
  final Widget Function(BuildContext context, AsyncValue<File> thumbnailFile)
      builder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => FetchThumbnailState();
}

class FetchThumbnailState extends ConsumerState<ImageThumbnail> {
  late bool hasThumbnail;
  @override
  void initState() {
    hasThumbnail =
        !widget.refresh && File(widget.media.previewFileName).existsSync();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (hasThumbnail) {
      return widget.builder(
        context,
        AsyncData(File(widget.media.previewFileName)),
      );
    }
    final service = ref.watch(thumbnailServiceProvider);
    return service.when(
      data: (service) {
        return FutureBuilder(
          future: service.createThumbnail(
            info: ThumbnailServiceDataIn(
              uuid: widget.media.id!,
              path: widget.media.path,
              thumbnailPath: widget.media.previewFileName,
              isVideo: widget.media.type == CLMediaType.video,
              dimension: 128,
            ),
            onData: () {
              if (mounted) {
                setState(() {
                  hasThumbnail = true;
                });
              }
            },
          ),
          builder: (context, snapshot) =>
              widget.builder(context, const AsyncLoading()),
        );
      },
      error: (_, __) => widget.builder(context, AsyncError(_, __)),
      loading: () => widget.builder(context, const AsyncLoading()),
    );
  }
}
