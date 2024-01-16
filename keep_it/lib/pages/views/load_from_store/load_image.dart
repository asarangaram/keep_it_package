import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadMedia extends ConsumerWidget {
  const LoadMedia({
    required this.mediaInfo,
    required this.onMediaLoaded,
    this.onLoading,
    this.onError,
    super.key,
  });

  final Widget Function(CLMedia media) onMediaLoaded;
  final Widget Function()? onLoading;
  final Widget Function(Object err, StackTrace stackTrace)? onError;
  final CLMedia mediaInfo;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(mediaProvider(mediaInfo));

    return mediaAsync.when(
      data: onMediaLoaded,
      loading: onLoading ?? () => const Center(child: CLLoadingView()),
      error: onError ??
          (err, _) => Center(child: CLErrorView(errorMessage: err.toString())),
    );
  }
}
