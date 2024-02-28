import 'dart:async';

import 'package:signals/signals_flutter.dart';
import 'package:sqlite_async/sqlite3.dart';

class Subscription<T> {
  Subscription(
    this.name, {
    required this.query,
    required this.watchTables,
    required this.fromMap,
  });

  final String name;

  final String query;
  final Set<String> watchTables;
  final T Function(Row row) fromMap;
  final signal = listSignal<T>([]);
}

class Subscribed<T> {
  Subscribed(
    this.subscription,
    this.stream,
  );
  Subscription<dynamic> subscription;
  StreamSubscription<List<T>> stream;
}
