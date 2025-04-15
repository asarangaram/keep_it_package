import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../entity/models/viewer_entity_mixin.dart';
import '../../../gallery_grid_view/models/tab_identifier.dart';
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
      List<ViewerEntityGroup<ViewerEntityMixin>>,
    ) bannersBuilder,
  }) builder;

  final List<ViewerEntityMixin> incoming;
  final List<Widget> Function(
    BuildContext,
    List<ViewerEntityGroup<ViewerEntityMixin>>,
  ) bannersBuilder;
  final bool disabled;
  final ViewIdentifier viewIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ViewerEntityMixin> filterred;
    final List<Widget> banners;
    if (incoming.isEmpty) {
      filterred = [];
      banners = [];
    } else {
      filterred =
          ref.watch(filterredMediaProvider(MapEntry(viewIdentifier, incoming)));

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
