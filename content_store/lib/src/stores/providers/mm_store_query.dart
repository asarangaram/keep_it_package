import 'package:minimal_mvn/minimal_mvn.dart';
import 'package:store/store.dart';

import 'mm_db.dart';

class LocalEntitiesNotifier extends MMNotifier<CLEntities> {
  LocalEntitiesNotifier(this.query) : super(const CLEntities()) {
    localStoreNotifierManager.notifier.addListener(localStorelistener);
  }
  final EntityQuery query;
  void localStorelistener() {
    notify(state.copyWith(isLoading: true));
    final clStore = localStoreNotifierManager.notifier.state;
    if (clStore.isInitialized) {
      clStore.getAll(query).then(
            (result) => notify(
              state.copyWith(entries: result, isLoading: false, errorMsg: ''),
            ),
          );
    } else if (clStore.errorMsg.isNotEmpty) {
      notify(state.copyWith(errorMsg: clStore.errorMsg, isLoading: false));
    } else {
      notify(state.copyWith(isLoading: clStore.isLoading));
    }
  }

  @override
  void dispose() {
    localStoreNotifierManager.notifier.removeListener(localStorelistener);
    super.dispose();
  }
}

class LocalStoreQueryManager extends MMManager<LocalEntitiesNotifier> {
  LocalStoreQueryManager(this.query)
      : super(() => LocalEntitiesNotifier(query), autodispose: true);
  final EntityQuery query;
}
