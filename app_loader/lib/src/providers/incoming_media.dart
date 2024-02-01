import 'dart:async';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_handler/share_handler.dart';

import '../models/incoming_media_stream.dart';

// Convert this to Future!
class IncomingMediaNotifier extends StateNotifier<List<CLMediaInfoGroup>> {
  IncomingMediaNotifier(super.initialSharedMedia) {
    final handler = ShareHandler.instance;
    intentDataStreamSubscription =
        handler.sharedMediaStream.listen((SharedMedia sharedMediaFiles) async {
      final infoGroup =
          await ExtCLMediaInfoGroup.fromSharedMedia(sharedMediaFiles);
      if (infoGroup?.isNotEmpty ?? false) {
        state = [...state, infoGroup!];
      }
    });
  }
  late final StreamSubscription<SharedMedia>? intentDataStreamSubscription;
  @override
  void dispose() {
    intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  void push(CLMediaInfoGroup media) {
    state = [...state, media];
  }

  void pop() {
    final media = state.firstOrNull;
    if (media != null) {
      for (final item in media.list) {
        item.deleteFile();
      }
    }
    state = state.removeFirstItem();
  }
}

final boottimeSharedImagesProvider =
    FutureProvider<CLMediaInfoGroup?>((ref) async {
  final handler = ShareHandler.instance;

  if (Platform.isAndroid || Platform.isIOS) {
    final sharedMedia = await handler.getInitialSharedMedia();

    return ExtCLMediaInfoGroup.fromSharedMedia(sharedMedia);
  }
  return null;
});

final incomingMediaProvider =
    StateNotifierProvider<IncomingMediaNotifier, List<CLMediaInfoGroup>>((ref) {
  final notifier = ref.watch(boottimeSharedImagesProvider).maybeWhen(
        orElse: () => null,
        data: (data) => data == null ? null : IncomingMediaNotifier([data]),
      );
  ref.watch(incomingMediaStreamProvider).when(
        data: (data) {
          print(data);
        },
        error: (_, __) {
          print('error: $_');
        },
        loading: () {},
      );
  return notifier ?? IncomingMediaNotifier([]);
});

final sharedMediaInfoGroup = StateProvider<CLMediaInfoGroup?>((ref) {
  final incomingMedia = ref.watch(incomingMediaProvider);
  return incomingMedia.firstOrNull;
});
