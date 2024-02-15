import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final appCacheDirectoryPathProvider = FutureProvider<String>((ref) async {
  final dir = await getApplicationCacheDirectory();
  return dir.path;
});
