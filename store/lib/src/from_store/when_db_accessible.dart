import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/db.dart';
import '../providers/db_manager.dart';

class WhenDBAccessible extends ConsumerWidget {
  const WhenDBAccessible({required this.builder, super.key});
  final Widget Function(DatabaseManager databaseManager) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbManagerAsync = ref.watch(dbManagerProvider);
    return dbManagerAsync.when(
      data: builder,
      error: (error, stackTrace) => CLErrorView(errorMessage: error.toString()),
      loading: CLLoadingView.new,
    );
  }
}
