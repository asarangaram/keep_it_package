import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:store/src/database/models/cl_media.dart';
import 'package:uuid/uuid.dart';

import '../../../database/providers/uuid.dart';
import '../../../device/widgets/when_devdir_accessible.dart';
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
    return GetDeviceDirectories(
      builder: (directories) {
        final uuidGenerator = ref.watch(uuidProvider);
        final uuid = uuidGenerator.v5(
          Uuid.NAMESPACE_URL,
          CLMediaDB.relativePath(widget.media.path, directories),
        );
        final previewFileName =
            path.join(directories.cacheDir.path, '$uuid.jpg');

        final hasThumbnail =
            !widget.refresh && File(previewFileName).existsSync();
        if (hasThumbnail) {
          return widget.builder(
            context,
            AsyncData(File(previewFileName)),
          );
        }

        final service = ref.watch(thumbnailServiceProvider);

        return service.when(
          data: (service) {
            return FutureBuilder(
              future: service.createThumbnail(
                info: ThumbnailServiceDataIn(
                  uuid: uuid,
                  path: widget.media.path,
                  thumbnailPath: previewFileName,
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
                    setState(() {
                      error = e;
                      this.st = st;
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
    );
  }
}
