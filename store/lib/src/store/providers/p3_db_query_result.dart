import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/m2_db_manager.dart';
import '../models/m3_db_reader.dart';

import 'p1_app_settings.dart';
import 'p2_db_manager.dart';

final dbQueryResultProvider =
    StreamProvider.family<List<dynamic>, DBReader<dynamic>>(
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
