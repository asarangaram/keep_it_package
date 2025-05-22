import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/services/entity_viewer_service/views/bottom_bar_page_view.dart';
import 'package:colan_services/services/entity_viewer_service/views/top_bar_page_view.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/entity_actions.dart';

class EntityPageView extends StatelessWidget {
  const EntityPageView({
    required this.parentIdentifier,
    required this.entities,
    required this.currentIndex,
    super.key,
  });
  final String parentIdentifier;
  final List<StoreEntity> entities;
  final int currentIndex;
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        mediaViewerUIStateProvider.overrideWith((ref) {
          return MediaViewerUIStateNotifier(
            MediaViewerUIState(
              entities: entities,
              currentIndex: currentIndex,
            ),
          );
        }),
      ],
      child: EntityPageView0(parentIdentifier: parentIdentifier),
    );
  }
}

class EntityPageView0 extends ConsumerWidget {
  const EntityPageView0({required this.parentIdentifier, super.key});
  final String parentIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showMenu =
        ref.watch(mediaViewerUIStateProvider.select((e) => e.showMenu));
    final entity =
        ref.read(mediaViewerUIStateProvider.select((e) => e.currentItem));
    final topBar = TopBarPageView(
      entity: entity,
    );

    final bottomBar = BottomBarPageView(
      bottomMenu: EntityActions.ofEntity(context, ref, entity as StoreEntity),
    );

    if (showMenu) {
      return CLScaffold(
        topMenu: topBar,
        banners: const [],
        body: SafeArea(
          child: MediaViewerCore(parentIdentifier: parentIdentifier),
        ),
        bottomMenu: bottomBar,
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: MediaViewerCore(parentIdentifier: parentIdentifier),
        ),
      );
    }
  }
}
