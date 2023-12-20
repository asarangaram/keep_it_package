import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../data/models/paginator.dart';
import 'collection_view.dart';

class PaginatedGrid extends ConsumerWidget {
  const PaginatedGrid({
    super.key,
    required this.collections,
    required this.constraints,
    required this.quickMenuScopeKey,
  });
  final List<Collection> collections;
  final BoxConstraints constraints;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const childSize = Size(100, 120);
    PaginatedList paginatedCollection =
        ref.watch(paginatedListProvider(PaginationInfo(
            items: collections,
            itemSize: childSize,
            pageSize: Size(
              constraints.maxWidth,
              constraints.maxHeight,
            ))));
    Random random = Random(42);
    return CLPageView(
      pageBuilder: (BuildContext context, int pageNum) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var r = 0; r < paginatedCollection.itemsInColumn; r++)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var c = 0; c < paginatedCollection.itemsInRow; c++)
                    Center(
                      child: SizedBox(
                        width: childSize.width,
                        height: childSize.height,
                        child: CollectionView(
                          collection:
                              paginatedCollection.getItem(pageNum, r, c),
                          quickMenuScopeKey: quickMenuScopeKey,
                          size: childSize,
                          random: random,
                        ),
                      ),
                    )
                ],
              )
          ],
        );
      },
      pageMax: paginatedCollection.pageMax,
    );
  }
}
