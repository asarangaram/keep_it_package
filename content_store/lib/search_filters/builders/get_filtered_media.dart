import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

// ignore: unused_import
import '../providers/filterred_media.dart';

class GetFilterredMediaByPass extends ConsumerWidget {
  const GetFilterredMediaByPass({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.incoming,
    super.key,
  });
  final Widget Function(CLMedias filterredMedia) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;
  final CLMedias incoming;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final filterred = ref.watch(filterredMediaProvider(incoming));
    return builder(incoming);
  }
}

class GetFilterredMedia extends ConsumerWidget {
  const GetFilterredMedia({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.incoming,
    required this.bannersBuilder,
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
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;
  final List<CLEntity> incoming;
  final List<Widget> Function(
    BuildContext,
    List<GalleryGroupCLEntity<CLEntity>>,
  ) bannersBuilder;
  final bool disabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (incoming.first.runtimeType == Collection || disabled) {
      return builder(incoming, bannersBuilder: (context, galleryMap) => []);
    }

    final medias = CLMedias(incoming.map((e) => e as CLMedia).toList());
    final filterred = ref.watch(filterredMediaProvider(medias));
    final topMsg = (filterred.entries.length < incoming.length)
        ? ' ${filterred.entries.length} out of '
            '${incoming.length} is Shown.'
        : null;
    final banners = [
      if (topMsg != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ColoredBox(
            color: Theme.of(context).colorScheme.onSurface,
            child: CLText.tiny(
              topMsg,
              color: Theme.of(context).colorScheme.surfaceBright,
            ),
          ),
        ),
    ];

    return builder(
      filterred.entries,
      bannersBuilder: (context, galleryMap) {
        return [
          ...banners,
          ...bannersBuilder(context, galleryMap),
        ];
      },
    );
  }
}
