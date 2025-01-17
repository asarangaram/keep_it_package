import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../adapters/provider/uri.dart';

class GetMediaUri extends ConsumerWidget {
  const GetMediaUri({
    required this.id,
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
    this.nullOnError = false,
  });
  final int id;
  final bool nullOnError;
  final Widget Function(Uri? uri) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eW = errorBuilder;
    final lW = loadingBuilder;

    final previewUri = ref.watch(mediaUriProvider(id));
    return previewUri.when(
      data: (uriAsync) => uriAsync.when(data: builder, error: eW, loading: lW),
      error: nullOnError ? (_, __) => builder(null) : eW,
      loading: lW,
    );
  }
}
