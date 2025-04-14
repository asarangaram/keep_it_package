import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../media_grouper/models/gallery_group.dart';
import '../providers/media_filters.dart';

class GetFilterredMedia extends ConsumerWidget {
  const GetFilterredMedia({
    required this.builder,
    required this.incoming,
    required this.bannersBuilder,
    required this.viewIdentifier,
    super.key,
    this.disabled = false,
  });
  final Widget Function(
    List<ViewerEntityMixin> filterred, {
    required List<Widget> Function(
      BuildContext,
      List<GalleryGroupStoreEntity<ViewerEntityMixin>>,
    ) bannersBuilder,
  }) builder;

  final List<ViewerEntityMixin> incoming;
  final List<Widget> Function(
    BuildContext,
    List<GalleryGroupStoreEntity<ViewerEntityMixin>>,
  ) bannersBuilder;
  final bool disabled;
  final ViewIdentifier viewIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<StoreEntity> filterred;
    final List<Widget> banners;
    if (incoming.isEmpty) {
      filterred = [];
      banners = [];
    } else {
      if ((incoming.first.runtimeType == StoreEntity &&
              (incoming.first as StoreEntity).isCollection) ||
          disabled) {
        return builder(incoming, bannersBuilder: (context, galleryMap) => []);
      }
      final medias = incoming.map((e) => e as StoreEntity).toList();
      filterred =
          ref.watch(filterredMediaProvider(MapEntry(viewIdentifier, medias)));

      final topMsg = (filterred.length < incoming.length)
          ? ' ${filterred.length} out of '
              '${incoming.length} matches'
          : null;
      banners = [
        if (topMsg != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Container(
              color: ShadTheme.of(context).colorScheme.mutedForeground,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Center(
                child: Text(
                  topMsg,
                  style: ShadTheme.of(context)
                      .textTheme
                      .small
                      .copyWith(color: ShadTheme.of(context).colorScheme.muted),
                ),
              ),
            ),
          ),
      ];
    }

    return builder(
      filterred,
      bannersBuilder: (context, galleryMap) {
        return [
          ...banners,
          ...bannersBuilder(context, galleryMap),
        ];
      },
    );
  }
}
