// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:share_handler/share_handler.dart';

@immutable
class IncomingMedia {
  const IncomingMedia({
    required this.status,
    required this.items,
  });

  final AsyncValue<bool> status;
  final List<CLMediaInfoGroup> items;

  IncomingMedia copyWith({
    AsyncValue<bool>? status,
    List<CLMediaInfoGroup>? items,
  }) {
    return IncomingMedia(
      status: status ?? this.status,
      items: items ?? this.items,
    );
  }

  factory IncomingMedia.init() {
    return const IncomingMedia(
      status: AsyncValue.data(true),
      items: [],
    );
  }

  @override
  bool operator ==(covariant IncomingMedia other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.status == status && listEquals(other.items, items);
  }

  @override
  int get hashCode => status.hashCode ^ items.hashCode;

  IncomingMedia push(CLMediaInfoGroup? media) {
    final List<CLMediaInfoGroup> items;
    if (media?.isNotEmpty ?? false) {
      items = [...this.items, media!];
    } else {
      items = this.items;
    }
    return copyWith(items: items, status: const AsyncValue.data(true));
  }

  IncomingMedia pop() {
    final media = items.firstOrNull;
    if (media != null) {
      for (final item in media.list) {
        item.deleteFile();
      }
    }
    return copyWith(items: items.removeFirstItem());
  }
}

class IncomingMediaNotifier extends StateNotifier<IncomingMedia> {
  IncomingMediaNotifier()
      : intentDataStreamSubscription = null,
        super(IncomingMedia.init()) {
    load();
  }

  StreamSubscription<SharedMedia>? intentDataStreamSubscription;

  @override
  void dispose() {
    intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    state = state.copyWith(status: const AsyncLoading());

    final handler = ShareHandler.instance;
    CLMediaInfoGroup? infoGroup;
    if (Platform.isAndroid || Platform.isIOS) {
      final sharedMedia = await handler.getInitialSharedMedia();
      infoGroup = await ExtCLMediaInfoGroup.fromSharedMedia(sharedMedia);
    }
    intentDataStreamSubscription = handler.sharedMediaStream.listen(listen);
    state = state.push(infoGroup);
  }

  void listen(SharedMedia sharedMediaFiles) {
    state = state.copyWith(status: const AsyncLoading());
    print('Got it!!!');
    pushGroup(sharedMediaFiles);
  }

  Future<void> pushGroup(SharedMedia sharedMediaFiles) async {
    final infoGroup =
        await ExtCLMediaInfoGroup.fromSharedMedia(sharedMediaFiles);
    print('consumed!!');
    state = state.push(infoGroup);
  }

  void onDone() {
    state = state.pop();
  }

  Future<void> onInsertFiles(
    List<String> paths, {
    int? collectionId,
  }) async {
    if (paths.isNotEmpty) {
      state = state.copyWith(status: const AsyncLoading());

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
      state = state.push(infoGroup);
    }
  }
}

final incomingMediaStreamProvider =
    StateNotifierProvider<IncomingMediaNotifier, IncomingMedia>((ref) {
  final notifier = IncomingMediaNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});

bool _disableInfoLogger = false;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
