abstract class PersistJson {
  Future<void> save(String key, String json);
  Future<String> load(String key, String defaultJson);
  Future<bool> remove(String key);
}
/* 

import 'package:shared_preferences/shared_preferences.dart';
class PersistJsonWithSharedPref implements PersistJson {
  factory PersistJsonWithSharedPref() => _instance;
  PersistJsonWithSharedPref._();
  static final PersistJsonWithSharedPref _instance =
      PersistJsonWithSharedPref._();

  @override
  Future<void> save(String key, String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json);
  }

  @override
  Future<String> load(String key, String defaultJson) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(key);

    return json ?? defaultJson;
  }

  @override
  Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}
 */
