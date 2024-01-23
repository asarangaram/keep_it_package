import '../models/cl_menu_item.dart';

extension Ext2DCLMenuItem on List<List<CLMenuItem>> {
  List<List<CLMenuItem>> insertOnDone(
    void Function() onDone,
  ) {
    return map((list) {
      return list.map((e) => e.extraActionOnSuccess(onDone)).toList();
    }).toList();
  }
}
