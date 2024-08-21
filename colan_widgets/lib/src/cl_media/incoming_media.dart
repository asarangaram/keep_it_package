// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_handler/share_handler.dart';
import 'package:store/store.dart';

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
      if (media.content != null && media.content!.isNotEmpty)
        if (media.content!.isURL())
          CLMediaBase(path: media.content!, type: CLMediaType.url)
        else
          CLMediaBase(path: 'text:${media.content!}', type: CLMediaType.text),
      if (media.imageFilePath != null)
        CLMediaBase(
          path: media.imageFilePath!,
          type: CLMediaType.image,
        ),
      if (media.attachments != null)
        ...media.attachments!.where((e) => e != null).map(
          (e) {
            return CLMediaBase(path: e!.path, type: toCLMediaType(e.type));
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

bool _disableInfoLogger = true;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
