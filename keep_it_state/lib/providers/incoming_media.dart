import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/extensions/ext_list.dart';

import 'package:share_handler/share_handler.dart';
import 'package:store/store.dart';

import '../models/cl_shared_media.dart';
import '../models/platform_support.dart';
import '../models/universal_media_source.dart';

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
      receiveSharedMedia(await handler.getInitialSharedMedia());

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

  void receiveSharedMedia(SharedMedia? media) {
    if (media == null) return;
    final attachements = [
      /* 
        not supported yet
      if (media.content != null && media.content!.isNotEmpty)
        if (media.content!.isURL())
          CLMediaBase(name: media.content!, type: CLMediaType.url, fExt: '.url')
        else
          CLMediaBase(
            name: 'text:${media.content!}',
            type: CLMediaType.text,
            fExt: '.txt',
          ), */
      if (media.imageFilePath != null)
        CLMediaBase(
          path: media.imageFilePath!,
          type: CLMediaType.image,
        ),
      if (media.attachments != null)
        ...media.attachments!.where((e) => e != null).map(
          (e) {
            return CLMediaBase(
              path: e!.path,
              type: toCLMediaType(e.type),
            );
          },
        ),
    ];

    if (attachements.isNotEmpty) {
      push(
        CLMediaFileGroup(
          entries: attachements,
          type: UniversalMediaSource.incoming,
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
          item.deleteFile();
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
