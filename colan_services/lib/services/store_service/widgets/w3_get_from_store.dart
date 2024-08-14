// ignore_for_file: lines_longer_than_80_chars

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/p3_db_reader.dart';

class GetFromStore<T> extends ConsumerWidget {
  const GetFromStore({
    required this.query,
    required this.builder,
    super.key,
  });
  final StoreQuery<T> query;
  final Widget Function(List<T> results) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dbReaderProvider(query));
    return ShowAsyncValue<List<dynamic>>(
      dataAsync,
      builder: (data) {
        return builder(data.map((e) => e as T).toList());
      },
    );
  }
}
