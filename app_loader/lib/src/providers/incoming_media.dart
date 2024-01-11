// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_handler/share_handler.dart';

import '../models/incoming_media.dart';

class IncomingMediaNotifier extends StateNotifier<IncomingMedia> {
  late final StreamSubscription<SharedMedia>? intentDataStreamSubscription;
  IncomingMediaNotifier(SharedMedia? initialSharedMedia)
      : super(IncomingMedia(initialSharedMedia)) {
    final handler = ShareHandler.instance;
    intentDataStreamSubscription = handler.sharedMediaStream.listen(listen);
  }
  @override
  void dispose() {
    intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> listen(SharedMedia sharedMediaFiles) async {
    state = await state.append(sharedMediaFiles);
  }

  Future<void> pop() async {
    state = await state.pop();
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
    StateNotifierProvider<IncomingMediaNotifier, IncomingMedia>((ref) {
  final notifier = ref.watch(boottimeSharedImagesProvider).maybeWhen(
        orElse: () => IncomingMediaNotifier(null),
        data: IncomingMediaNotifier.new,
      );
  ref.onDispose(() {
    // notifier.dispose();
  });
  return notifier;
});
