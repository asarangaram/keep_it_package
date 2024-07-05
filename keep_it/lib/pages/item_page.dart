import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../widgets/empty_state.dart';

class CollectionItemPage extends ConsumerWidget {
  const CollectionItemPage({
    required this.id,
    required this.collectionId,
    required this.parentIdentifier,
    super.key,
  });
  final int collectionId;
  final int id;
  final String parentIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetMediaByCollectionId(
      collectionId: collectionId,
      buildOnData: (items) {
        if (items.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            CLPopScreen.onPop(context);
          });
          return const EmptyState(message: 'No Media');
        }
        final initialMedia = items.where((e) => e.id == id).firstOrNull;
        final initialMediaIndex =
            initialMedia == null ? 0 : items.indexOf(initialMedia);

        return FullscreenLayout(
          useSafeArea: false,
          child: MediaViewService.pageView(
            media: items,
            parentIdentifier: parentIdentifier,
            initialMediaIndex: initialMediaIndex,
          ),
        );
      },
    );
  }
}

class ItemViewPage extends ConsumerWidget {
  const ItemViewPage({
    required this.id,
    required this.parentIdentifier,
    super.key,
  });

  final int id;
  final String parentIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FullscreenLayout(
      child: GetMedia(
        id: id,
        buildOnData: (media) {
          if (media == null) {
            return const EmptyState(); // TODO
          }

          return CLPopScreen.onSwipe(
            child: MediaViewService(
              media: media,
              parentIdentifier: parentIdentifier,
              actionControl: ActionControl.editOnly(),
            ),
          );
        },
      ),
    );
  }
}
