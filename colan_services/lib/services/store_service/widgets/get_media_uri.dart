import 'package:colan_services/services/store_service/models/media_manager.dart';
import 'package:colan_services/services/store_service/providers/media_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../internal/widgets/broken_image.dart';
import '../../../internal/widgets/shimmer.dart';
import '../providers/a0_media_uri.dart';
import '../providers/a1_preview_uri.dart';

class GetPreviewUri extends ConsumerWidget {
  const GetPreviewUri(this.media, {required this.builder, super.key});
  final Widget Function(Uri uri) builder;
  final CLMedia media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(previewUriProvider(media));
    return asyncValue.when(
      data: builder,
      error: BrokenImage.show,
      loading: GreyShimmer.show,
    );
  }
}

class GetMediaUri extends ConsumerWidget {
  const GetMediaUri(this.media, {required this.builder, super.key});
  final Widget Function(Uri uri) builder;
  final CLMedia media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(mediaUriProvider(media));
    return asyncValue.when(
      data: builder,
      error: BrokenImage.show,
      loading: GreyShimmer.show,
    );
  }
}

class GetMediaManager extends ConsumerWidget {
  const GetMediaManager(this.media, {required this.builder, super.key});
  final Widget Function(MediaManager mediaManager) builder;
  final CLMedia media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(mediaManagerProvider(media));
    return asyncValue.when(
      data: builder,
      error: BrokenImage.show,
      loading: GreyShimmer.show,
    );
  }
}
