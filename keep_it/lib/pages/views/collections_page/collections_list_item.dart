import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

import 'collection_preview.dart';

class CollectionsListItem extends StatelessWidget {
  const CollectionsListItem(
    this.collection, {
    super.key,
    this.isSelected,
    required this.random,
    this.onTap,
  });

  final bool? isSelected;
  final Collection collection;
  final Random random;
  final Function()? onTap;
  final double previewSize = 128; // TODO: should come from settings

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: previewSize,
      child: CLListTile(
        isSelected: isSelected ?? false,
        title: collection.label,
        subTitle: collection.description ?? "",
        leading: SizedBox.square(
          dimension: previewSize,
          child: CollectionPreview(random: random),
        ),
        onTap: onTap,
      ),
    );
  }
}
