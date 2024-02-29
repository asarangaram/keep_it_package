import 'dart:async';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/src/store/providers/p1_app_settings.dart';

import '../models/m1_app_settings.dart';
import '../models/m2_db_manager.dart';
import '../models/m3_db_query.dart';

import 'p2_db_manager.dart';

class DBQueryResultNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  DBQueryResultNotifier({
    required this.dbManagerNew,
    required this.appPreferences,
    required this.dbQuery,
  }) : super(const AsyncValue.loading()) {
    sub = dbManagerNew.db
        .watchRows(
          dbQuery.sql,
          triggerOnTables: dbQuery.triggerOnTables,
          parameters: dbQuery.parameters ?? [],
        )
        .map(
          (rows) => rows.map((e) => dbQuery.fromMap(preprocess(e))).toList(),
        )
        .listen((value) async {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        return value;
      });
    });
  }
  DBQuery<dynamic> dbQuery;
  AppSettings appPreferences;
  DBManager dbManagerNew;
  late final StreamSubscription<List<dynamic>> sub;

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  Map<String, dynamic> preprocess(
    Map<String, dynamic> map, {
    bool validate = true,
  }) {
    return map.map((key, value) {
      final String v;
      if (key == 'path' &&
          CLMediaType.values
              .where((e) => e.isFile)
              .map((e) => e.name)
              .contains(map['type'])) {
        final path = value as String;
        final collectionID = map['collection_id'] as int;

        if (validate && !File(path).existsSync()) {
          throw Exception('file not found');
        }
        final prefix = appPreferences.validPrefix(collectionID);
        if (validate && path.startsWith(prefix)) {
          throw Exception('Media is not placed in appropriate folder');
        }
        return MapEntry(key, path.replaceFirst(prefix, ''));
      } else {
        v = value as String;
        return MapEntry(key, v);
      }
    });
  }

  Map<String, dynamic> postprocess(Map<String, dynamic> map) {
    return map.map((key, value) {
      if (key == 'path' &&
          CLMediaType.values
              .where((e) => e.isFile)
              .map((e) => e.name)
              .contains(map['type'])) {
        final collectionID = map['collection_id'] as int;
        final path = value as String;

        return MapEntry(
          key,
          '${appPreferences.validPrefix(collectionID)}/$path',
        );
      } else {
        return MapEntry(key, value);
      }
    });
  }
}

final dbQueryResultProvider = StateNotifierProvider.family<
    AsyncValue<DBQueryResultNotifier>,
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
                  appPreferences: appPreferences,
                  dbManagerNew: dbManager,
                  dbQuery: dbQuery,
                ),
              ),
            ),
      );
});
