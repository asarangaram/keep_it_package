import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/media_view_modifier.dart';

import 'uri_config.dart';

class MediaViewModifierNotifier
    extends FamilyAsyncNotifier<MediaViewModifier, Uri> {
  MediaViewModifierNotifier();

  @override
  FutureOr<MediaViewModifier> build(Uri arg) async {
    final uriConfig = await ref.watch(uriConfigurationProvider(arg).future);

    return MediaViewModifier(
      quarterTurns: uriConfig.quarterTurns,
      onRotate: (quarterTurns) async {
        await ref
            .read(uriConfigurationProvider(arg).notifier)
            .onChange(quarterTurns: quarterTurns);
      },
    );
  }
}

final mediaViewModifierProvider = AsyncNotifierProvider.family<
    MediaViewModifierNotifier, MediaViewModifier, Uri>(
  MediaViewModifierNotifier.new,
);
