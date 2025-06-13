import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

@immutable
class StoreTask {
  const StoreTask({
    required this.items,
    required this.fromStore,
  });

  final List<CLEntity> items;
  final CLStore fromStore;
}
