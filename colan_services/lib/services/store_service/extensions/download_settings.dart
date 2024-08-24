import 'package:shared_preferences/shared_preferences.dart';
import 'package:store/store.dart';

extension StoreExtOnDownloadSettings on DownloadSettings {
  static Future<DownloadSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('DownloadSettings');
    if (json != null) {
      return DownloadSettings.fromJson(json);
    }
    return DownloadSettings.preferred();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('DownloadSettings', toJson());
  }
}
