import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../adapters/provider/uri.dart';

class GetPreviewUri extends ConsumerWidget {
  const GetPreviewUri({
    required this.id,
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final int id;
  final Widget Function(Uri uri) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewUri = ref.watch(previewUriProvider(id));
    return previewUri.when(
      data: (uriAsync) => uriAsync.when(
        data: builder,
        error: errorBuilder,
        loading: loadingBuilder,
      ),
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }
}
