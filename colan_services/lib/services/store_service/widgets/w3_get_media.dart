import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/media_provider.dart';

class GetMedia extends ConsumerWidget {
  const GetMedia({
    required this.buildOnData,
    required this.id,
    super.key,
  });
  final Widget Function(CLMedia? media) buildOnData;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      buildOnData(ref.watch(mediaProvider).getMedia(id));
}

class GetMediaByCollectionId extends ConsumerWidget {
  const GetMediaByCollectionId({
    required this.buildOnData,
    this.collectionId,
    super.key,
  });
  final Widget Function(List<CLMedia> items) buildOnData;
  final int? collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => buildOnData(
        ref.watch(mediaProvider).getMediaByCollectionId(collectionId),
      );
}

class GetMediaMultiple extends ConsumerWidget {
  const GetMediaMultiple({
    required this.buildOnData,
    required this.idList,
    super.key,
  });
  final Widget Function(List<CLMedia> items) buildOnData;
  final List<int> idList;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      buildOnData(ref.watch(mediaProvider).getMediaMultiple(idList));
}

class GetPinnedMedia extends ConsumerWidget {
  const GetPinnedMedia({
    required this.buildOnData,
    super.key,
  });
  final Widget Function(List<CLMedia> items) buildOnData;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      buildOnData(ref.watch(mediaProvider).getPinnedMedia());
}

class GetStaleMedia extends ConsumerWidget {
  const GetStaleMedia({
    required this.buildOnData,
    super.key,
  });
  final Widget Function(List<CLMedia> items) buildOnData;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      buildOnData(ref.watch(mediaProvider).getStaleMedia());
}

class GetDeletedMedia extends ConsumerWidget {
  const GetDeletedMedia({
    required this.buildOnData,
    super.key,
  });
  final Widget Function(List<CLMedia> items) buildOnData;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      buildOnData(ref.watch(mediaProvider).getDeletedMedia());
}
