/* import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:store/store.dart';

import '../../store_service/widgets/the_store.dart';
import '../model/thumbnail_services.dart';
import '../provider/thumbnail_services.dart';

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
  Object? error;
  StackTrace? st;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return widget.builder(context, AsyncError(error!, st!));
    }
    if (!File(TheStore.of(context).getMediaPath(widget.media)).existsSync()) {
      try {
        throw Exception('file not found');
      } catch (e, st) {
        if (mounted) {
          setState(() {
            error = e;
            this.st = st;
          });
        }
      }
    }
    final previewPath = TheStore.of(context).getPreviewPath(widget.media);

    final hasThumbnail = !widget.refresh && File(previewPath).existsSync();
    if (hasThumbnail) {
      return widget.builder(
        context,
        AsyncData(File(previewPath)),
      );
    }

    final service = ref.watch(thumbnailServiceProvider);

    return service.when(
      data: (service) {
        return FutureBuilder(
          future: service.createThumbnail(
            info: ThumbnailServiceDataIn(
              uuid: path.basenameWithoutExtension(previewPath),
              path: TheStore.of(context).getMediaPath(widget.media),
              thumbnailPath: previewPath,
              isVideo: widget.media.type == CLMediaType.video,
              dimension: 256,
            ),
            onData: () {
              if (mounted) {
                setState(() {});
              }
            },
            onError: (errorString) {
              try {
                throw Exception('errorString');
              } catch (e, st) {
                if (mounted) {
                  setState(() {
                    error = e;
                    this.st = st;
                  });
                }
              }
            },
          ),
          builder: (context, snapshot) =>
              widget.builder(context, const AsyncLoading()),
        );
      },
      error: (e, st) => widget.builder(context, AsyncError(e, st)),
      loading: () => widget.builder(context, const AsyncLoading()),
    );
  }
}
 */
