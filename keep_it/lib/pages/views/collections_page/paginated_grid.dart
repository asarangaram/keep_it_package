import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/data/models/paginator.dart';
import 'package:keep_it/pages/views/collections_page/collections_grid_item.dart';
import 'package:store/store.dart';

class PaginatedGrid extends ConsumerWidget {
  const PaginatedGrid({
    required this.collections,
    required this.constraints,
    required this.quickMenuScopeKey,
    super.key,
  });
  final List<Collection> collections;
  final BoxConstraints constraints;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const childSize = Size(100, 120);
    final paginatedCollection = ref.watch(
      paginatedListProvider(
        PaginationInfo(
          items: collections,
          itemSize: childSize,
          pageSize: Size(
            constraints.maxWidth,
            constraints.maxHeight,
          ),
        ),
      ),
    );
    final random = Random(42);
    return CLPageView(
      pageBuilder: (BuildContext context, int pageNum) {
        return RowColumnGrid(
          itemsInColumn: paginatedCollection.itemsInColumn,
          itemsInRow: paginatedCollection.itemsInRow,
          itemBuilder: (context, r, c) {
            return Center(
              child: SizedBox(
                width: childSize.width,
                height: childSize.height,
                child: CollectionsGridItem(
                  collection:
                      paginatedCollection.getItem(pageNum, r, c) as Collection,
                  quickMenuScopeKey: quickMenuScopeKey,
                  size: childSize,
                  random: random,
                ),
              ),
            );
          },
        );
      },
      pageMax: paginatedCollection.pageMax,
    );
  }
}

class RowColumnGrid extends StatelessWidget {
  const RowColumnGrid({
    required this.itemsInColumn,
    required this.itemsInRow,
    required this.itemBuilder,
    super.key,
  });

  final int itemsInColumn;
  final int itemsInRow;
  final Widget Function(BuildContext context, int r, int c) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        for (var r = 0; r < itemsInColumn; r++)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (var c = 0; c < itemsInRow; c++)
                  Expanded(child: itemBuilder(context, r, c)),
              ],
            ),
          ),
      ],
    );
  }
}
