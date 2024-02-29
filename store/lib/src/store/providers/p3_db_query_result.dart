import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/src/store/providers/p1_app_settings.dart';
import 'package:store/store.dart';

import '../models/m1_app_settings.dart';
import '../models/m2_db_manager.dart';
import '../models/m3_db_query.dart';

import 'p2_db_manager.dart';

class DBQueryResultNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  DBQueryResultNotifier({
    required this.dbManagerNew,
    required this.appSettings,
    required this.dbQuery,
  }) : super(const AsyncValue.loading()) {
    sub = dbManagerNew.db
        .watchRows(
          dbQuery.sql,
          triggerOnTables: dbQuery.triggerOnTables,
          parameters: dbQuery.parameters ?? [],
        )
        .map(
          (rows) => rows
              .map(
                (e) => dbQuery.fromMap(
                  dbQuery.preprocess?.call(e, appSettings: appSettings) ?? e,
                ),
              )
              .toList(),
        )
        .listen((value) async {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        return value;
      });
    });
  }
  DBQuery<dynamic> dbQuery;
  AppSettings appSettings;
  DBManager dbManagerNew;
  late final StreamSubscription<List<dynamic>> sub;

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }
}

final dbQueryResultProvider =
    StreamProvider.family<List<dynamic>, DBQuery<dynamic>>(
        (ref, dbQuery) async* {
  final dbManager = await ref.watch(dbManagerProvider.future);
  final appSettings = await ref.watch(appSettingsProvider.future);
  final sub = dbManager.db
      .watchRows(
        dbQuery.sql,
        triggerOnTables: dbQuery.triggerOnTables,
        parameters: dbQuery.parameters ?? [],
      )
      .map(
        (rows) => rows
            .map(
              (e) => dbQuery.fromMap(
                dbQuery.preprocess?.call(e, appSettings: appSettings) ?? e,
              ),
            )
            .toList(),
      );
  await for (final res in sub) {
    yield res;
  }
});
/* 
final dbQueryResultProvider = StateNotifierProvider.family<
    DBQueryResultNotifier,
    AsyncValue<List<dynamic>>,
    DBQuery<dynamic>>((ref, dbQuery) {
  return ref.watch(dbManagerProvider).when(
        error: AsyncError.new,
        loading: AsyncLoading.new,
        data: (dbManager) => ref.watch(appSettingsProvider).when(
              error: AsyncError.new,
              loading: AsyncLoading.new,
              data: (appPreferences) => AsyncData(
                DBQueryResultNotifier(
                  appSettings: appPreferences,
                  dbManagerNew: dbManager,
                  dbQuery: dbQuery,
                ),
              ),
            ),
      );
}); */
