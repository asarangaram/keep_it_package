import 'package:content_store/db_service/widgets/broken_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db_service/widgets/shimmer.dart';
import '../providers/uri.dart';

class GetMediaUri extends ConsumerWidget {
  const GetMediaUri({
    required this.id,
    required this.builder,
    super.key,
    this.errorBuilder,
    this.loadingBuilder,
    this.nullOnError = false,
  });
  final int id;
  final bool nullOnError;
  final Widget Function(Uri? uri) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eW = errorBuilder ?? BrokenImage.show;
    final lW = loadingBuilder ?? GreyShimmer.show;

    final previewUri = ref.watch(mediaUriProvider(id));
    return previewUri.when(
      data: (uriAsync) => uriAsync.when(data: builder, error: eW, loading: lW),
      error: nullOnError ? (_, __) => builder(null) : eW,
      loading: lW,
    );
  }
}
