import 'dart:async';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_handler/share_handler.dart';

class IncomingMediaNotifier extends StateNotifier<List<SharedMedia>> {
  IncomingMediaNotifier(super.initialSharedMedia) {
    final handler = ShareHandler.instance;
    intentDataStreamSubscription =
        handler.sharedMediaStream.listen((SharedMedia sharedMediaFiles) {
      state = [...state, sharedMediaFiles];
    });
  }
  late final StreamSubscription<SharedMedia>? intentDataStreamSubscription;
  @override
  void dispose() {
    intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  void pop() {
    state = state.removeFirstItem();
  }
}

final boottimeSharedImagesProvider = FutureProvider<SharedMedia?>((ref) async {
  final handler = ShareHandler.instance;

  if (Platform.isAndroid || Platform.isIOS) {
    return handler.getInitialSharedMedia();
  }
  return null;
});

final incomingMediaProvider =
    StateNotifierProvider<IncomingMediaNotifier, List<SharedMedia>>((ref) {
  final notifier = ref.watch(boottimeSharedImagesProvider).maybeWhen(
        orElse: () => null,
        data: (data) => data == null ? null : IncomingMediaNotifier([data]),
      );
  return notifier ?? IncomingMediaNotifier([]);
});

final sharedMediaInfoGroup = FutureProvider<CLMediaInfoGroup>((ref) async {
  final incomingMedia = ref.watch(incomingMediaProvider);
  return incomingMedia.firstOrNull.toCLMediaInfoGroup();
});
