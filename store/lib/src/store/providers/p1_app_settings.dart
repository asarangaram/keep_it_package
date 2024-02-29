import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../models/m1_app_settings.dart';

final appSettingsProvider = FutureProvider<AppSettings>((ref) async {
  final directories = DeviceDirectories(
    //container: (await getLibraryDirectory()).parent,
    container: (await getApplicationDocumentsDirectory()).parent,
    docDir: await getApplicationDocumentsDirectory(),
    cacheDir: await getApplicationCacheDirectory(),
  );
  return AppSettings(directories);
});
