/* import 'package:colan_cmdline/src/cache/cached_server.dart';
import 'package:store/store.dart';

import 'cl_server.dart';

class ServerCollection extends Collection {
  const ServerCollection({
    required super.label,
    required this.isDirty,
    super.id,
    super.description,
    super.createdDate,
    super.updatedDate,
  });
  final bool isDirty;

  Future<void> downloadCollections(CachedServer server) async {
    final json = await server.getEndpoint('/collection');
    final collections = Collections.fromJson(json);
    if (collections.entries.isEmpty) return;

    for (final collection in collections.entries) {
      await server.cachedStore.upsertCollection(collection);
    }
  }
}

extension ExtServerOnCollection on Collections {}

extension ExtServerOnCLMedias on CLMedias {
  static Future<CLMedias> fetch(CLServer server) async {
    final json = await server.getEndpoint('/media');

    final medias = CLMedias.fromJson(json);
    return medias;
  }
}
 */