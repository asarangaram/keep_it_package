// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../views/appearance/cl_error_view.dart';
import '../views/appearance/cl_loading_view.dart';

class ShowAsyncValue<T> extends ConsumerWidget {
  const ShowAsyncValue(
    this.asyncData, {
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    super.key,
  });
  final AsyncValue<T> asyncData;
  final Widget Function(T data) builder;
  final Widget Function(Object object, StackTrace st)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncData.when(
      loading: loadingBuilder != null ? loadingBuilder! : CLLoadingView.new,
      error: errorBuilder != null ? errorBuilder! : _ShowAsyncError.new,
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
