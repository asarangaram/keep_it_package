import 'package:cl_entity_viewers/cl_entity_viewers.dart';

import 'package:flutter/material.dart';

import 'bottom_bar_page_view.dart';
import 'top_bar_page_view.dart';

class EntityPageView extends StatelessWidget {
  const EntityPageView({
    required this.parentIdentifier,
    super.key,
  });
  final String parentIdentifier;

  @override
  Widget build(BuildContext context) {
    return CLEntitiesPageView(
      parentIdentifier: parentIdentifier,
      topMenu: const TopBarPageView(),
      bottomMenu: const BottomBarPageView(),
    );
  }
}
