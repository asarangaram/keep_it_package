import 'package:cl_entity_viewers/cl_entity_viewers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/on_swipe.dart';
import 'bottom_bar_page_view.dart';
import 'top_bar.dart';

class KeepItPageView extends StatelessWidget {
  const KeepItPageView(
      {required this.viewIdentifier,
      required this.entity,
      required this.siblings,
      super.key});

  final ViewIdentifier viewIdentifier;
  final ViewerEntityMixin entity;
  final List<ViewerEntityMixin> siblings;

  @override
  Widget build(BuildContext context) {
    return OnSwipe(
      child: CLEntitiesPageViewScope(
        siblings: siblings,
        currentEntity: entity,
        child: CLEntitiesPageView(
          parentIdentifier: viewIdentifier.parentID,
          topMenu: TopBar(
            viewIdentifier: viewIdentifier,
            entityAsync: AsyncData(entity),
            children: const [],
          ),
          bottomMenu: const BottomBarPageView(),
        ),
      ),
    );
  }
}
