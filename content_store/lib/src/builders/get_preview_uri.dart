import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/uri.dart';
import '../models/broken_image.dart';
import '../models/shimmer.dart';

class GetPreviewUri extends ConsumerWidget {
  const GetPreviewUri({
    required this.id,
    required this.builder,
    super.key,
    this.errorBuilder,
    this.loadingBuilder,
  });
  final int id;
  final Widget Function(Uri uri) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eW = errorBuilder ?? BrokenImage.show;
    final lW = loadingBuilder ?? GreyShimmer.show;

    final previewUri = ref.watch(previewUriProvider(id));
    return previewUri.when(
      data: (uriAsync) => uriAsync.when(data: builder, error: eW, loading: lW),
      error: eW,
      loading: lW,
    );
  }
}
