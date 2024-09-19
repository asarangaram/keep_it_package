import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/downloader_status.dart';

final downloaderStatusProvider = StateProvider<DownloaderStatus>((ref) {
  return const DownloaderStatus();
});
