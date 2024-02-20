// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_handler/share_handler.dart';

class IncomingMediaNotifier extends StateNotifier<List<CLMediaInfoGroup>> {
  IncomingMediaNotifier()
      : intentDataStreamSubscription = null,
        super([]) {
    load();
  }

  StreamSubscription<SharedMedia>? intentDataStreamSubscription;

  Future<void> load() async {
    final handler = ShareHandler.instance;
    if (Platform.isAndroid || Platform.isIOS) {
      receiveSharedMedia(await handler.getInitialSharedMedia());
    }
    intentDataStreamSubscription = handler.sharedMediaStream.listen(
      receiveSharedMedia,
    );
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
          CLMedia(path: media.content!, type: CLMediaType.url)
        else
          CLMedia(path: 'text:${media.content!}', type: CLMediaType.text),
      if (media.imageFilePath != null)
        CLMedia(
          path: media.imageFilePath!,
          type: CLMediaType.image,
        ),
      if (media.attachments != null)
        ...media.attachments!.where((e) => e != null).map(
          (e) {
            return CLMedia(path: e!.path, type: toCLMediaType(e.type));
          },
        ),
    ];

    if (attachements.isNotEmpty) {
      push(
        CLMediaInfoGroup(
          list: attachements,
        ),
      );
    }
  }

  void push(CLMediaInfoGroup item) {
    state = [...state, item];
  }

  void pop() {
    final media = state.firstOrNull;
    if (media?.isNotEmpty ?? false) {
      for (final item in media!.list) {
        item.deleteFile();
      }
    }
    state = state.removeFirstItem();
  }

  void onDiscard() => pop();
}

final incomingMediaStreamProvider =
    StateNotifierProvider<IncomingMediaNotifier, List<CLMediaInfoGroup>>((ref) {
  final notifier = IncomingMediaNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});

bool _disableInfoLogger = false;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
