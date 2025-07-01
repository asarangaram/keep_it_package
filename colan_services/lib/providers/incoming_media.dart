import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:share_handler/share_handler.dart';
import 'package:store_tasks/store_tasks.dart';

import '../../extensions/ext_list.dart';
import '../models/cl_media_candidate.dart';
import '../models/platform_support.dart';

class IncomingMediaNotifier extends StateNotifier<List<CLMediaFileGroup>> {
  IncomingMediaNotifier()
      : intentDataStreamSubscription = null,
        super([]) {
    load();
  }

  StreamSubscription<SharedMedia>? intentDataStreamSubscription;

  Future<void> load() async {
    final handler = ShareHandler.instance;
    if (ColanPlatformSupport.isMobilePlatform) {
      await receiveSharedMedia(await handler.getInitialSharedMedia());

      intentDataStreamSubscription = handler.sharedMediaStream.listen(
        receiveSharedMedia,
      );
    }
  }

  @override
  void dispose() {
    intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  static CLMediaType toCLMediaType(SharedAttachmentType type) {
    return switch (type) {
      SharedAttachmentType.image => CLMediaType.image,
      SharedAttachmentType.video => CLMediaType.video,
      SharedAttachmentType.audio => CLMediaType.audio,
      SharedAttachmentType.file => CLMediaType.file,
    };
  }

  Future<void> receiveSharedMedia(SharedMedia? media) async {
    if (media == null) return;
    final attachements = [
      if (media.content != null && media.content!.isNotEmpty)
        if (CLMediaContent.isURL(media.content!))
          CLMediaURI(Uri.parse(media.content!))
        else
          CLMediaText(media.content!),
      if (media.imageFilePath != null)
        CLMediaUnknown(
          media.imageFilePath!,
        ),
      if (media.attachments != null)
        ...media.attachments!.map((e) => CLMediaUnknown(e!.path)),
    ];

    if (attachements.isNotEmpty) {
      push(
        CLMediaFileGroup(
          entries: attachements,
          contentOrigin: ContentOrigin.incoming,
        ),
      );
    }
  }

  void push(CLMediaFileGroup item) {
    state = [...state, item];
  }

  bool pop() {
    final media = state.firstOrNull;
    if (media != null) {
      if (ColanPlatformSupport.isMobilePlatform && media.isNotEmpty) {
        for (final item in media.entries) {
          if (item is CLMediaFile) {
            item.deleteFile();
          }
        }
      }
      state = state.removeFirstItem();
      return true;
    }
    return false;
  }
}

final incomingMediaStreamProvider =
    StateNotifierProvider<IncomingMediaNotifier, List<CLMediaFileGroup>>((ref) {
  final notifier = IncomingMediaNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});

/* bool _disableInfoLogger = true;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
} */
