import 'dart:async';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_handler/share_handler.dart';

class IncomingMediaNotifier extends StateNotifier<List<CLMediaInfoGroup>> {
  IncomingMediaNotifier(super.initialSharedMedia) {
    final handler = ShareHandler.instance;
    intentDataStreamSubscription =
        handler.sharedMediaStream.listen((SharedMedia sharedMediaFiles) async {
      state = [...state, await sharedMediaFiles.toCLMediaInfoGroup()];
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
    state = state.removeFirstItem();
  }
}

final boottimeSharedImagesProvider =
    FutureProvider<CLMediaInfoGroup?>((ref) async {
  final handler = ShareHandler.instance;

  if (Platform.isAndroid || Platform.isIOS) {
    final sharedMedia = await handler.getInitialSharedMedia();
    if (sharedMedia == null) return null;
    return sharedMedia.toCLMediaInfoGroup();
  }
  return null;
});

final incomingMediaProvider =
    StateNotifierProvider<IncomingMediaNotifier, List<CLMediaInfoGroup>>((ref) {
  final notifier = ref.watch(boottimeSharedImagesProvider).maybeWhen(
        orElse: () => null,
        data: (data) => data == null ? null : IncomingMediaNotifier([data]),
      );
  return notifier ?? IncomingMediaNotifier([]);
});

final sharedMediaInfoGroup = StateProvider<CLMediaInfoGroup?>((ref) {
  final incomingMedia = ref.watch(incomingMediaProvider);
  return incomingMedia.firstOrNull;
});
