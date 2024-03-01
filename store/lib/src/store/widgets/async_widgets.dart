// ignore_for_file: lines_longer_than_80_chars

import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/m3_db_reader.dart';
import '../providers/p3_db_query_result.dart';

class DBReaderWidget<T> extends ConsumerWidget {
  const DBReaderWidget({
    required this.query,
    required this.builder,
    super.key,
  });
  final DBReader<T> query;
  final Widget Function(List<T> results) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dbQueryResultProvider(query));
    return ShowAsyncValue<List<dynamic>>(
      dataAsync,
      builder: (data) {
        return builder(data.map((e) => e as T).toList());
      },
    );
  }
}

class ShowAsyncValue<T> extends ConsumerWidget {
  const ShowAsyncValue(
    this.asyncData, {
    required this.builder,
    super.key,
  });
  final AsyncValue<T> asyncData;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncData.when(
      loading: CLLoadingView.new,
      error: _ShowAsyncError.new,
      data: (data) {
        try {
          return builder(data);
        } catch (e, st) {
          return _ShowAsyncError(e, st);
        }
      },
    );
  }
}

class _ShowAsyncError extends ConsumerWidget {
  const _ShowAsyncError(this.object, this.st, {super.key});
  final Object object;
  final StackTrace st;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLErrorView(errorMessage: object.toString());
  }
}
