import 'package:store/store.dart';

import 'cl_server.dart';

extension ExtServerOnCollection on Collections {
  static Future<Collections> fetch(CLServer server) async {
    final json = await server.getEndpoint('/collection');

    final collections = Collections.fromJson(json);
    return collections;
  }
}

extension ExtServerOnCLMedias on CLMedias {
  static Future<CLMedias> fetch(CLServer server) async {
    final json = await server.getEndpoint('/media');

    final medias = CLMedias.fromJson(json);
    return medias;
  }
}
