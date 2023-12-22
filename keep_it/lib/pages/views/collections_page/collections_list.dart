import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'collection_preview.dart';

class CollectionsList extends ConsumerWidget {
  const CollectionsList({
    super.key,
    required this.collectionList,
  });

  final List<Collection> collectionList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (collectionList.isEmpty) {
      throw Exception("This widget can't handle empty colections");
    }
    Random random = Random(42);

    return Container(
      // decoration: BoxDecoration(border: Border.all()),
      child: ListView.builder(
        itemCount: collectionList.length,
        itemBuilder: (context, index) {
          return CollectionsListItem(
            collection: collectionList[index],
            random: random,
          );
        },
      ),
    );
  }
}

class CollectionsListItem extends ConsumerWidget {
  const CollectionsListItem({
    super.key,
    required this.collection,
    required this.random,
  });
  final Collection collection;
  final Random random;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      //decoration: BoxDecoration(border: Border.all()),
      child: CLListTile(
        title: collection.label,
        subTitle: collection.description ?? "",
        preview: Stack(
          children: [
            CollectionPreview(random: random),
          ],
        ),
        onTap: () {},
        height: 128,
      ),
    );
  }
}

class CLListTile extends StatelessWidget {
  final Widget? preview;
  final String title;
  final String? subTitle;
  final Function? onTap;
  final Function? onLongPress;
  final Function? onDoubleTap;

  final Color? tileColor;
  final double? height;

  // Constructor for the custom list tile
  const CLListTile({
    super.key,
    this.preview,
    required this.title,
    this.subTitle,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.tileColor,
    required this.height, // Make height required for clarity
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        height: height,
        child: InkWell(
          onTap: () => onTap,
          onDoubleTap: () => onDoubleTap,
          onLongPress: () => onLongPress,
          child: Row(
            children: [
              SizedBox.square(dimension: height, child: preview),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CLText.veryLarge(
                        title,
                        // textAlign: TextAlign.center,
                      ),
                      if (subTitle != null) ...[
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: CLText.small(
                            subTitle!,
                            textAlign: TextAlign.start,
                          ),
                        )
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
