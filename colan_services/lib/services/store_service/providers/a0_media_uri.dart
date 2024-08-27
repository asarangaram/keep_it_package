import 'package:colan_services/services/store_service/models/media_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'media_manager.dart';

class MediaUriNotifier extends StateNotifier<AsyncValue<Uri>> {
  MediaUriNotifier(this.ref, this.media, this.asycnValueLocalInfo)
      : super(const AsyncValue.loading()) {
    load();
  }
  Ref ref;
  final CLMedia media;
  AsyncValue<MediaManager> asycnValueLocalInfo;

  Future<void> load() async {
    asycnValueLocalInfo.whenOrNull(
      error: (error, stackTrace) => state = AsyncValue.error(error, stackTrace),
      data: (mediaInfo) async {
        try {
          final mediaURI = mediaInfo.getValidMediaUri();
          if (mediaURI != null) {
            state = const AsyncValue.loading();
            state = await AsyncValue.guard(() async {
              return mediaInfo.mediaFileURI;
            });
          }
        } catch (e, st) {
          state = AsyncValue.error(e, st);
        }
      },
    );
  }
}

final mediaUriProvider =
    StateNotifierProvider.family<MediaUriNotifier, AsyncValue<Uri>, CLMedia>(
        (ref, media) {
  final mediaInfo = ref.watch(mediaManagerProvider(media));
  return MediaUriNotifier(ref, media, mediaInfo);
});
