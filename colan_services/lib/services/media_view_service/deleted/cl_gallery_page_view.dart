/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/media_filters.dart';

import '../models/viewer_entity_mixin.dart';
import '../models/tab_identifier.dart';
import '../providers/page_controller.dart';

class CLGalleryPageView extends ConsumerWidget {
  const CLGalleryPageView(
      {required this.viewIdentifier,
      required this.incoming,
      required this.itemBuilder,
      this.filtersDisabled = false,
      super.key,
      required this.whenEmpty});

  final ViewIdentifier viewIdentifier;
  final List<ViewerEntityMixin> incoming;

  final Widget Function(
    BuildContext,
    ViewerEntityMixin,
  ) itemBuilder;

  final bool filtersDisabled;
  final Widget whenEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ViewerEntityMixin> filterred;
    if (filtersDisabled) {
      filterred = incoming;
    } else {
      filterred =
          ref.watch(filterredMediaProvider(MapEntry(viewIdentifier, incoming)));
    }
    if (filterred.isEmpty) {
      return whenEmpty;
    }
    if (filterred.length == 1) {
      return itemBuilder(context, filterred[0]);
    }

    final pageController = ref.watch(pageControllerProvider(viewIdentifier));
    final pageControls =
        ref.watch(pageControllerProvider(viewIdentifier).notifier);
    return Stack(
      children: [
        PageView.builder(
          controller: pageController,
          itemCount: filterred.length,
          physics:
              pageControls.locked ? const NeverScrollableScrollPhysics() : null,
          onPageChanged: (index) {
            ref
                .read(pageControllerProvider(viewIdentifier).notifier)
                .goToPage(index);
          },
          itemBuilder: (context, index) =>
              itemBuilder(context, filterred[index]),
        ),
      ],
    );
  }
}
 */
