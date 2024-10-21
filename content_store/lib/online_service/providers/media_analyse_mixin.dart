import 'package:store/store.dart';

import '../../extensions/ext_cl_media.dart';
import '../models/media_change_tracker.dart';

mixin MediaAnalyseMixin {
  static void log(
    String message, {
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    /* dev.log(
      message,
      level: level,
      error: error,
      stackTrace: stackTrace,
      name: 'Online Service | Server',
    ); */
  }
  Future<List<MediaChangeTracker>> analyse(
    List<Map<String, dynamic>> serverItemsMap,
    List<CLMedia> localItems,
  ) async {
    final trackers = <MediaChangeTracker>[];
    log('items in local: ${localItems.length}');
    log('items in Server: ${serverItemsMap.length}');
    for (final serverEntry in serverItemsMap) {
      final localEntry = localItems
          .where(
            (e) =>
                e.serverUID == serverEntry['serverUID'] ||
                e.md5String == serverEntry['md5String'],
          )
          .firstOrNull;

      final tracker = MediaChangeTracker(
        current: localEntry,
        update: StoreExtCLMedia.mediaFromServerMap(localEntry, serverEntry),
      );

      if (!tracker.isActionNone) {
        trackers.add(tracker);
      }
      if (localEntry != null) {
        localItems.remove(localEntry);
      }
    }
    // For remaining items
    trackers.addAll(
      localItems.map((e) => MediaChangeTracker(current: e, update: null)),
    );
    return trackers;
  }
}
