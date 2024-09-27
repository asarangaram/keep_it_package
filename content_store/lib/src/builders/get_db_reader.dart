import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/db_store.dart';

class GetDBReader extends ConsumerWidget {
  const GetDBReader({
    required this.builder,
    super.key,
    this.errorBuilder,
    this.loadingBuilder,
  });
  final Widget Function(StoreReader dbReader) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(storeProvider);

    return storeAsync.when(
      data: (store) => builder(store.reader),
      error: errorBuilder ?? (_, __) => Container(),
      loading: loadingBuilder ?? Container.new,
    );
  }
}

class GetStore extends ConsumerWidget {
  const GetStore({
    required this.builder,
    super.key,
    this.errorBuilder,
    this.loadingBuilder,
  });
  final Widget Function(Store store) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(storeProvider);

    return storeAsync.when(
      data: builder,
      error: errorBuilder ?? (_, __) => Container(),
      loading: loadingBuilder ?? Container.new,
    );
  }
}
