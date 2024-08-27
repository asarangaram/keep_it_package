import 'package:colan_services/services/store_service/models/media_local_info_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'a2_local_media_info_manager.dart';

class MediaUriNotifier extends StateNotifier<AsyncValue<Uri>> {
  MediaUriNotifier(this.ref, this.media, this.asycnValueLocalInfo)
      : super(const AsyncValue.loading()) {
    load();
  }
  Ref ref;
  final CLMedia media;
  AsyncValue<MediaLocalInfoManager> asycnValueLocalInfo;

  Future<void> load() async {
    asycnValueLocalInfo.whenOrNull(
      error: (error, stackTrace) => state = AsyncValue.error(error, stackTrace),
      data: (mediaInfo) async {
        try {
          final previewURI = mediaInfo.getValidMediaUri();
          if (previewURI != null) {
            state = const AsyncValue.loading();
            state = await AsyncValue.guard(() async {
              return mediaInfo.previewFileURI;
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
  final mediaInfo = ref.watch(mediaInfoProvider(media));
  return MediaUriNotifier(ref, media, mediaInfo);
});
