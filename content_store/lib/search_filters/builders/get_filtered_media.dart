import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../providers/media_filters.dart';

class GetFilterredMedia extends ConsumerWidget {
  const GetFilterredMedia({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.incoming,
    required this.bannersBuilder,
    required this.parentIdentifier,
    super.key,
    this.disabled = false,
  });
  final Widget Function(
    List<CLEntity> filterred, {
    required List<Widget> Function(
      BuildContext,
      List<GalleryGroupCLEntity<CLEntity>>,
    ) bannersBuilder,
  }) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final List<CLEntity> incoming;
  final List<Widget> Function(
    BuildContext,
    List<GalleryGroupCLEntity<CLEntity>>,
  ) bannersBuilder;
  final bool disabled;
  final String parentIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (incoming.first.runtimeType == Collection || disabled) {
      return builder(incoming, bannersBuilder: (context, galleryMap) => []);
    }
    final medias = incoming.map((e) => e as CLMedia).toList();
    final filterred =
        ref.watch(filterredMediaProvider(MapEntry(parentIdentifier, medias)));

    try {
      final topMsg = (filterred.length < incoming.length)
          ? ' ${filterred.length} out of '
              '${incoming.length} is Shown.'
          : null;
      final banners = [
        if (topMsg != null)
          ShadBadge(
            child: Text(
              topMsg,
            ),
          ),
      ];

      return builder(
        filterred,
        bannersBuilder: (context, galleryMap) {
          return [
            ...banners,
            ...bannersBuilder(context, galleryMap),
          ];
        },
      );
    } catch (e, st) {
      return errorBuilder(e, st);
    }
  }
}

final filterredMediaProvider =
    StateProvider.family<List<CLMedia>, MapEntry<String, List<CLMedia>>>(
        (ref, mediaMap) {
  final mediaFilters = ref.watch(mediaFiltersProvider(mediaMap.key));
  return mediaFilters.apply(mediaMap.value);
});
