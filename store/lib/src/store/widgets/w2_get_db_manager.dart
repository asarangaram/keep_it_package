import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/src/store/models/m2_db_manager.dart';
import 'package:store/src/store/providers/p2_db_manager.dart';

import 'async_widgets.dart';

class GetDBManager extends ConsumerWidget {
  const GetDBManager({required this.builder, super.key});
  final Widget Function(DBManager dbManager) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShowAsyncValue<DBManager>(
      ref.watch(dbManagerProvider),
      builder: builder,
    );
  }
}
