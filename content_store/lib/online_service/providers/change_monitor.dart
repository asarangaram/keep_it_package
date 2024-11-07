import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:store/store.dart';

import '../../db_service/providers/db_reader.dart';
import '../../db_service/providers/store_updater.dart';

@immutable
class LocalChangeMonitor {
  const LocalChangeMonitor({required this.hasChange});
  final bool hasChange;
}

final localChangeMonitorProvider =
    StreamProvider<LocalChangeMonitor>((ref) async* {
  final storeUpdater = await ref.watch(storeUpdaterProvider.future);

  final controller = StreamController<LocalChangeMonitor>();
  final dbQuery = storeUpdater.store.reader.getQuery<CLMedia>(DBQueries.medias);

  Future<LocalChangeMonitor> loader() async {
    final res =
        (await storeUpdater.store.reader.readMultiple(dbQuery)).nonNullableSet;
    final change = LocalChangeMonitor(
      hasChange: res.where((e) => e.isEdited ?? false).isNotEmpty,
    );
    print('change detected? : $change');
    return change;
  }

  ref.listen(refreshReaderProvider, (prev, curr) async {
    if (prev != curr) {
      controller.add(await loader());
    }
  });

  yield await loader();
  yield* controller.stream;
});
