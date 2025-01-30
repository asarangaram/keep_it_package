import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
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
    required this.viewIdentifier,
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
  final ViewIdentifier viewIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (incoming.first.runtimeType == Collection || disabled) {
      return builder(incoming, bannersBuilder: (context, galleryMap) => []);
    }
    final medias = incoming.map((e) => e as CLMedia).toList();
    final filterred =
        ref.watch(filterredMediaProvider(MapEntry(viewIdentifier, medias)));

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
