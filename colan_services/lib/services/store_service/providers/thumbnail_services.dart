import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/thumbnail_services.dart';

final thumbnailServiceProvider = FutureProvider<ThumbnailService>((ref) async {
  final service = ThumbnailService();
  await service.startService();
  return service;
});
