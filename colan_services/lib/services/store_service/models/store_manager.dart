import 'package:flutter/foundation.dart';

import 'package:store/store.dart';

import '../../gallery_service/models/m5_gallery_pin.dart';
import '../../settings_service/models/m1_app_settings.dart';

@immutable
class StoreManager {
  StoreManager({
    required this.store,
    required this.appSettings,
  });
  final Store store;
  final AppSettings appSettings;
  final AlbumManager albumManager = AlbumManager(albumName: 'KeepIt');
  final String tempCollectionName = '*** Recently Captured';
}
