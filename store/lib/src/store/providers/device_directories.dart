import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../models/device_directories.dart';

final docDirProvider = FutureProvider<DeviceDirectories>((ref) async {
  return DeviceDirectories(
    //container: (await getLibraryDirectory()).parent,
    container: (await getApplicationDocumentsDirectory()).parent,
    docDir: await getApplicationDocumentsDirectory(),
    cacheDir: await getApplicationCacheDirectory(),
  );
});
