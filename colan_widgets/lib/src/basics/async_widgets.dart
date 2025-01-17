// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowAsyncValue<T> extends ConsumerWidget {
  const ShowAsyncValue(
    this.asyncData, {
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final AsyncValue<T> asyncData;
  final Widget Function(T data) builder;
  final Widget Function(Object object, StackTrace st) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncData.when(
      loading: loadingBuilder,
      error: errorBuilder,
      data: (data) {
        try {
          return builder(data);
        } catch (e, st) {
          return errorBuilder(e, st);
        }
      },
    );
  }
}
