import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/m2_db_manager.dart';
import '../models/m3_db_query.dart';

import 'p1_app_settings.dart';
import 'p2_db_manager.dart';

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
                e,
                appSettings: appSettings,
                validate: true,
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
