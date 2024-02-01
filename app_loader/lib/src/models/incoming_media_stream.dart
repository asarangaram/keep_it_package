import 'dart:async';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:share_handler/share_handler.dart';

class IncomingMedia {}

class IncomingMediaNotifier extends StreamNotifier<CLMediaInfoGroup?> {
  late final StreamController<CLMediaInfoGroup?> streamController;
  late final StreamSink<CLMediaInfoGroup?> streamSink;
  late final Stream<CLMediaInfoGroup?> stream;
  StreamSubscription<SharedMedia>? intentDataStreamSubscription;
  @override
  Stream<CLMediaInfoGroup?> build() {
    streamController = StreamController<CLMediaInfoGroup?>();
    streamSink = streamController.sink;
    load();
    return streamController.stream;
  }

  Future<void> load() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final handler = ShareHandler.instance;
      CLMediaInfoGroup? infoGroup;
      if (Platform.isAndroid || Platform.isIOS) {
        final sharedMedia = await handler.getInitialSharedMedia();
        infoGroup = await ExtCLMediaInfoGroup.fromSharedMedia(sharedMedia);
      }
      intentDataStreamSubscription = handler.sharedMediaStream.listen(listen);
      if (infoGroup?.isNotEmpty ?? false) {
        return infoGroup;
      } else {
        return null;
      }
    });
  }

  Future<void> listen(SharedMedia sharedMediaFiles) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final infoGroup =
          await ExtCLMediaInfoGroup.fromSharedMedia(sharedMediaFiles);
      if (infoGroup?.isNotEmpty ?? false) {
        return infoGroup;
      }
      return null;
    });
  }

  void onDone() {
    streamSink.add(null);
  }

  Future<void> onInsertFiles(
    List<String> paths, {
    int? collectionId,
  }) async {
    if (paths.isNotEmpty) {
      state = const AsyncValue.loading();

      state = await AsyncValue.guard(() async {
        final stopwatch = Stopwatch()..start();
        final media = <CLMedia>[];
        for (final item in paths) {
          final clMedia = switch (lookupMimeType(item)) {
            (final String mime) when mime.startsWith('image') =>
              await ExtCLMediaFile.clMediaWithPreview(
                path: item,
                type: CLMediaType.image,
              ),
            (final String mime) when mime.startsWith('video') =>
              await ExtCLMediaFile.clMediaWithPreview(
                path: item,
                type: CLMediaType.video,
              ),
            (final String mime) when mime.startsWith('audio') =>
              CLMedia(path: item, type: CLMediaType.audio),
            _ => CLMedia(path: item, type: CLMediaType.file),
          };

          media.add(clMedia);
        }
        final infoGroup = CLMediaInfoGroup(media, targetID: collectionId);
        stopwatch.stop();
        _infoLogger(
          'Picker Processing time: ${stopwatch.elapsedMilliseconds} milliseconds'
          ' [${stopwatch.elapsed}]',
        );
        return infoGroup;
      });
    }
  }

  void dispose() {
    intentDataStreamSubscription?.cancel();
  }
}

final incomingMediaStreamProvider =
    StreamNotifierProvider<IncomingMediaNotifier, CLMediaInfoGroup?>(
  () {
    return IncomingMediaNotifier();
  },
);

bool _disableInfoLogger = false;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
