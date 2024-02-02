// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:app_loader/src/models/cl_shared_media.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_handler/share_handler.dart';

class IncomingMediaNotifier extends StateNotifier<List<CLIncomingMedia>> {
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

  void receiveSharedMedia(SharedMedia? media) {
    if (media == null) return;
    final attachements = [
      if (media.content != null)
        CLIncomingItem(content: media.content!, type: CLMediaType.text),
      if (media.imageFilePath != null)
        CLIncomingItem(
          content: media.imageFilePath!,
          type: CLMediaType.image,
        ),
      if (media.attachments != null)
        ...media.attachments!.map(
          (e) {
            return CLIncomingItem.fromSharedAttachment(e!);
          },
        ),
    ];

    if (attachements.isNotEmpty) {
      push(
        CLIncomingMedia(
          attachements,
        ),
      );
    }
  }

  void push(CLIncomingMedia item) => state = [...state, item];
  void pop() {
    final media = state.firstOrNull;
    media?.destroy();
    state = state.removeFirstItem();
  }

  void onDone() => pop();
}

final incomingMediaStreamProvider =
    StateNotifierProvider<IncomingMediaNotifier, List<CLIncomingMedia>>((ref) {
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
