import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/services/entity_viewer_service/views/entity_grid_view.dart';
import 'package:flutter/material.dart';

import '../widgets/on_swipe.dart';

class KeepItGridView extends StatelessWidget {
  const KeepItGridView(
      {required this.viewIdentifier,
      required this.parent,
      required this.children,
      super.key});

  final ViewIdentifier viewIdentifier;
  final ViewerEntityMixin? parent;
  final List<ViewerEntityMixin> children;

  @override
  Widget build(BuildContext context) {
    return OnSwipe(
      child: CLEntitiesGridViewScope(
        child: EntityGridView(
          viewIdentifier: viewIdentifier,
          parent: parent,
          children: children,
        ),
      ),
    );
  }
}
