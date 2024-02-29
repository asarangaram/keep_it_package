import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:sqlite_async/sqlite_async.dart';
import '../models/db_manager_new.dart';
import '../models/db_query.dart';
import 'device_directories.dart';

class DBFetchNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  DBFetchNotifier(this.db, this.dbQuery) : super(const AsyncValue.loading()) {
    sub = db
        .watchRows(
          dbQuery.sql,
          triggerOnTables: dbQuery.triggerOnTables,
          parameters: dbQuery.parameters ?? [],
        )
        .map((rows) => rows.map((e) => dbQuery.fromMap(e)).toList())
        .listen((value) async {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        return value;
      });
    });
  }
  DBQuery<dynamic> dbQuery;
  SqliteDatabase db;
  late final StreamSubscription<List<dynamic>> sub;

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }
}

final dbFetchProviderProvider = StateNotifierProvider.family<
    AsyncValue<DBFetchNotifier>,
    AsyncValue<List<dynamic>>,
    DBQuery<dynamic>>((ref, dbQuery) {
  return ref.watch(dbNewProvider).when(
        data: (db) => AsyncData(DBFetchNotifier(db, dbQuery)),
        error: AsyncError.new,
        loading: AsyncLoading.new,
      );
});

final dbNewProvider = FutureProvider<SqliteDatabase>((ref) async {
  final directories = await ref.watch(deviceDirectoriesProvider.future);
  final appDir = directories.docDir;
  final fullPath = path.join(appDir.path, 'keepIt.db');
  return DBManagerNew.createInstances(fullPath);
});
