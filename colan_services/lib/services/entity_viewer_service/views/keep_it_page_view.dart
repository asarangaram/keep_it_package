import 'package:cl_entity_viewers/cl_entity_viewers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/on_swipe.dart';
import 'bottom_bar_page_view.dart';
import 'top_bar.dart';

class KeepItPageView extends StatelessWidget {
  const KeepItPageView(
      {required this.entity, required this.siblings, super.key});

  final ViewerEntity entity;
  final ViewerEntities siblings;

  @override
  Widget build(BuildContext context) {
    return OnSwipe(
      child: CLEntitiesPageViewScope(
        siblings: siblings,
        currentEntity: entity,
        child: CLEntitiesPageView(
          topMenuBuilder: (currentEntity) => TopBar(
            entityAsync: AsyncData(currentEntity),
            children: const ViewerEntities([]),
          ),
          bottomMenu: const BottomBarPageView(),
        ),
      ),
    );
  }
}
