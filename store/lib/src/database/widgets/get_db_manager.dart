import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/db_manager.dart';
import '../providers/db_manager.dart';



class GetDBManager extends ConsumerWidget {
  const GetDBManager({required this.builder, super.key});
  final Widget Function(DBManager databaseManager) builder;

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
