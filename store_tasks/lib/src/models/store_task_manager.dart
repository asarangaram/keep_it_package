import 'store_task.dart';

abstract class StoreTaskManager {
  bool push(StoreTask task);
  StoreTask pop();
}
