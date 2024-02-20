import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import 'package:uuid/uuid.dart';

import '../../../from_store/from_store.dart';
import '../../../providers/uuid.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WhenDeviceDirectoriesAccessible(
      builder: (directories) {
        final uuidGenerator = ref.watch(uuidProvider);
        final uuid = uuidGenerator.v5(Uuid.NAMESPACE_URL, widget.media.path);
        String previewFileName;
        final randomName = '$uuid.jpg';
        previewFileName = path.join(directories.cacheDir.path, randomName);

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
