import 'dart:io';

import 'package:colan_widgets/src/services/image_services/model/thumbnail_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import 'package:uuid/uuid.dart';

import '../../../models/cl_media.dart';
import '../../resources/providers/cache_dir.dart';
import '../../resources/providers/uuid.dart';
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
  bool hasThumbnail = false;
  String? previewFileName;
  @override
  void initState() {
    if (widget.media.id != null) {
      previewFileName = widget.media.previewFileName;
      hasThumbnail = !widget.refresh && File(previewFileName!).existsSync();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appCacheDirectoryPathAsync = ref.watch(appCacheDirectoryPathProvider);
    if (hasThumbnail) {
      return widget.builder(
        context,
        AsyncData(File(previewFileName!)),
      );
    }
    return appCacheDirectoryPathAsync.when(
      data: (appCacheDirectoryPath) {
        final uuidGenerator = ref.watch(uuidProvider);
        final uuid = uuidGenerator.v5(Uuid.NAMESPACE_URL, widget.media.path);
        if (previewFileName == null) {
          final randomName = '$uuid.jpg';
          previewFileName = path.join(appCacheDirectoryPath, randomName);
        }

        final service = ref.watch(thumbnailServiceProvider);

        return service.when(
          data: (service) {
            return FutureBuilder(
              future: service.createThumbnail(
                info: ThumbnailServiceDataIn(
                  uuid: uuid,
                  path: widget.media.path,
                  thumbnailPath: previewFileName!,
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
      },
      error: (_, __) => widget.builder(context, AsyncError(_, __)),
      loading: () => widget.builder(context, const AsyncLoading()),
    );
  }
}
