import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db_service/models/uri.dart';
import '../../storage_service/providers/directories.dart';

final mediaPathDeterminerProvider =
    FutureProvider<MediaPathDeterminer>((ref) async {
  final directories = await ref.watch(deviceDirectoriesProvider.future);

  return MediaPathDeterminer(directories: directories);
});
