import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../extensions/download_settings.dart';

class DownloadSettingsNotifier
    extends StateNotifier<AsyncValue<DownloadSettings>> {
  DownloadSettingsNotifier() : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    final settings = StoreExtOnDownloadSettings.load();

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return settings;
    });
  }
}

final downloadSettingsProvider = StateNotifierProvider<DownloadSettingsNotifier,
    AsyncValue<DownloadSettings>>((ref) {
  return DownloadSettingsNotifier();
});
