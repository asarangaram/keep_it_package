import 'dart:async';

import 'package:content_store/content_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:store/store.dart';

import '../../db_service/providers/db_reader.dart';
import '../../db_service/providers/store_updater.dart';
import '../models/server.dart';

@immutable
class ChangeMonitor {
  const ChangeMonitor({required this.hasChange});
  final bool hasChange;
}

final serverChangeMonitorProvider = StreamProvider<ChangeMonitor>((ref) async* {
  final controller = StreamController<ChangeMonitor>();
  Future<ChangeMonitor> loader(Server server) async {
    return ChangeMonitor(hasChange: server.identity != server.previousIdentity);
  }

  ref.listen(serverProvider, (prev, curr) async {
    if (prev != curr) {
      controller.add(await loader(curr));
    }
  });
  yield const ChangeMonitor(hasChange: false);
  yield* controller.stream;
  return;
});

final localChangeMonitorProvider = StreamProvider<ChangeMonitor>((ref) async* {
  final storeUpdater = await ref.watch(storeUpdaterProvider.future);

  final controller = StreamController<ChangeMonitor>();
  final dbQuery = storeUpdater.store.reader.getQuery<CLMedia>(DBQueries.medias);

  Future<ChangeMonitor> loader() async {
    final res =
        (await storeUpdater.store.reader.readMultiple(dbQuery)).nonNullableSet;
    final change = ChangeMonitor(
      hasChange: res.where((e) => e.isEdited ?? false).isNotEmpty,
    );
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
