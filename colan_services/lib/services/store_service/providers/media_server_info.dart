import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'db_reader.dart';
import 'store.dart';

final mediaServerInfoProvider =
    FutureProvider.family<MediaServerInfo?, CLMedia>((ref, media) async {
  final store = await ref.watch(storeProvider.future);

  final query =
      store.getQuery(DBQueries.mediaServerInfoById, parameters: [media.id])
          as StoreQuery<MediaServerInfo>;

  return (await ref.watch(dbReaderProvider(query).future)).firstOrNull
      as MediaServerInfo?;
});
