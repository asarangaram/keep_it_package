import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/services/entity_viewer_service/views/entity_page_view.dart';
import 'package:flutter/material.dart';

import '../widgets/on_swipe.dart';

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
        child: EntityPageView(
          parentIdentifier: viewIdentifier.parentID,
        ),
      ),
    );
  }
}
