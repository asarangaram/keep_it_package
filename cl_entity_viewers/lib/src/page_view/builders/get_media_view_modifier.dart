import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/media_view_modifier.dart';
import '../providers/media_view_modifier.dart';

class GetMediaViewModifier extends ConsumerWidget {
  const GetMediaViewModifier({
    required this.uri,
    required this.builder,
    super.key,
  });
  final Uri uri;
  final Widget Function(
    MediaViewModifier? viewModifier,
  ) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModifierAsync = ref.watch(mediaViewModifierProvider(uri));

    return builder(
      viewModifierAsync.whenOrNull(
        data: (data) => data,
      ),
    );
  }
}
