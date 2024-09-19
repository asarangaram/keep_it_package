import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/downloader.dart';
import 'downloader_status.dart';

final downloaderProvider = StateProvider<Downloader>((ref) {
  return Downloader(
    (status) => ref.read(downloaderStatusProvider.notifier).state = status,
  );
});
