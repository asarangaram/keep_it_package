import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadMedia extends ConsumerWidget {
  const LoadMedia({
    super.key,
    required this.mediaInfo,
    required this.onMediaLoaded,
  });

  final Widget Function(CLMedia media) onMediaLoaded;
  final CLMedia mediaInfo;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(mediaProvider(mediaInfo));

    return mediaAsync.when(
        data: (media) => onMediaLoaded(media),
        loading: () => const Center(child: CLLoadingView()),
        error: (err, _) =>
            Center(child: CLErrorView(errorMessage: err.toString())));
  }
}
