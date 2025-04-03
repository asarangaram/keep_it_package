import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

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
    List<CLEntity> filterred, {
    required List<Widget> Function(
      BuildContext,
      List<GalleryGroupCLEntity<CLEntity>>,
    ) bannersBuilder,
  }) builder;

  final List<CLEntity> incoming;
  final List<Widget> Function(
    BuildContext,
    List<GalleryGroupCLEntity<CLEntity>>,
  ) bannersBuilder;
  final bool disabled;
  final ViewIdentifier viewIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (incoming.first.runtimeType == CLMedia || disabled) {
      return builder(incoming, bannersBuilder: (context, galleryMap) => []);
    }
    final medias = incoming.map((e) => e as CLMedia).toList();
    final filterred =
        ref.watch(filterredMediaProvider(MapEntry(viewIdentifier, medias)));

    final topMsg = (filterred.length < incoming.length)
        ? ' ${filterred.length} out of '
            '${incoming.length} matches'
        : null;
    final banners = [
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
