import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../storage_service/models/file_system/models/cl_directories.dart';
import '../models/m1_app_settings.dart';

final appSettingsProvider = FutureProvider<AppSettings>((ref) async {
  final directories = CLDirectories(
    persistent: await getApplicationSupportDirectory(),
    temporary: await getApplicationCacheDirectory(),
    systemTemp: Directory.systemTemp,
  );
  return AppSettings(directories);
});
