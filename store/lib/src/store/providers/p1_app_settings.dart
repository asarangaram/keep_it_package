import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final appSettingsProvider = FutureProvider<AppSettings>((ref) async {
  final directories = CLDirectories(
    persistent: await getApplicationDocumentsDirectory(),
    temporary: await getApplicationCacheDirectory(),
    systemTemp: Directory.systemTemp,
  );

  return AppSettings(directories);
});
