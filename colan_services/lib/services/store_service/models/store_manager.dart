import 'package:colan_services/services/storage_service/models/file_system/models/cl_directories.dart';
import 'package:flutter/foundation.dart';

import 'package:store/store.dart';

import '../../gallery_service/models/m5_gallery_pin.dart';

@immutable
class StoreManager {
  StoreManager({
    required this.store,
    required this.deviceDirectories,
  });
  final Store store;
  final CLDirectories deviceDirectories;
  final AlbumManager albumManager = AlbumManager(albumName: 'KeepIt');
  final String tempCollectionName = '*** Recently Captured';
}
