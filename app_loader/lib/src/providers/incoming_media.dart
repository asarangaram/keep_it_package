// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_handler/share_handler.dart';

import '../models/cl_shared_media.dart';
import '../models/on_device_media.dart';
import '../models/universal_media_source.dart';

class IncomingMediaNotifier extends StateNotifier<List<CLSharedMedia>> {
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

  Future<void> receiveSharedMedia(SharedMedia? media) async {
    if (media == null) return;
    final attachements = [
      // TODO(anandas): Handle URL
      /* if (media.content != null && media.content!.isNotEmpty)
        if (media.content!.isURL())
          CLMedia(path: media.content!, type: CLMediaType.url)
        else
          CLMedia(path: 'text:${media.content!}', type: CLMediaType.text), */
      if (media.imageFilePath != null)
        await OnDeviceMedia.create(media.imageFilePath!),
      if (media.attachments != null)
        for (final attachment in media.attachments!)
          if (attachment != null) await OnDeviceMedia.create(attachment.path),
    ];

    if (attachements.isNotEmpty) {
      push(
        CLSharedMedia(
          entries: attachements,
          type: UniversalMediaSource.incoming,
        ),
      );
    }
  }

  void push(CLSharedMedia item) {
    state = [...state, item];
  }

  bool pop() {
    final media = state.firstOrNull;
    if (media != null) {
      if (ColanPlatformSupport.isMobilePlatform && media.isNotEmpty) {
        for (final item in media.entries) {
          if (item.id == null) {
            OnDeviceMedia(item).delete();
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
    StateNotifierProvider<IncomingMediaNotifier, List<CLSharedMedia>>((ref) {
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
