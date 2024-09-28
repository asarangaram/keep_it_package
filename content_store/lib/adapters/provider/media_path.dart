import 'package:content_store/online_service/providers/server.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db_service/models/uri.dart';
import '../../online_service/providers/uri_with_online.dart';
import '../../storage_service/providers/directories.dart';
import 'support_online.dart';

final mediaPathDeterminerProvider =
    FutureProvider<MediaPathDeterminer>((ref) async {
  final directories = await ref.watch(deviceDirectoriesProvider.future);
  final supportOnline = await ref.watch(supportOnlineProvider.future);
  final server = ref.watch(serverProvider);
  if (supportOnline) {
    return MediaPathDeterminerWithOnlineSupport(
      directories: directories,
      server: server.identity,
    );
  }
  return MediaPathDeterminer(directories: directories);
});
