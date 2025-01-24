// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/db_reader.dart';

class GetFromStore<T> extends ConsumerWidget {
  const GetFromStore({
    required this.query,
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final StoreQuery<T> query;
  final Widget Function(List<T> results) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dbReaderProvider(query));
    return dataAsync.when(
      error: errorBuilder,
      loading: loadingBuilder,
      data: (data) {
        return builder(data.map((e) => e as T).toList());
      },
    );
  }
}
