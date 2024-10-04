import '../../db_service/models/store_updater.dart';

extension ServerExt on StoreUpdater {
  Future<void> sync() async {
    await Future<void>.delayed(const Duration(seconds: 10));
  }
}
