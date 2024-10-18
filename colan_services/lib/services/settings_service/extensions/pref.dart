import 'package:shared_preferences/shared_preferences.dart';
import 'package:store/store.dart';

extension StoreExtOnDownloadMediaGlobalPreference
    on DownloadMediaGlobalPreference {
  static Future<DownloadMediaGlobalPreference> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('DownloadMediaGlobalPreference');
    if (json != null) {
      return DownloadMediaGlobalPreference.fromJson(json);
    }
    return DownloadMediaGlobalPreference.preferred();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('DownloadMediaGlobalPreference', toJson());
  }
}
