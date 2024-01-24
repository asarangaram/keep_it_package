import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cl_matrix_2d.dart';

class CLMatrix3D extends ConsumerWidget {
  const CLMatrix3D({
    required this.pages,
    required this.rows,
    required this.columns,
    required this.itemCount,
    required this.itemBuilder,
    required this.pageController,
    super.key,
    this.layers = 1,
  });

  final int pages;
  final int rows;
  final int columns;
  final int itemCount;
  final int layers;
  final Widget Function(BuildContext context, int index, int layer) itemBuilder;
  final PageController pageController;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageView.builder(
      controller: pageController,
      itemCount: pages,
      itemBuilder: (context, pageNum) {
        final itemsInCurrentPage = ((pageNum * rows * columns) < itemCount)
            ? rows * columns
            : itemCount ~/ (rows * columns);

        return CLMatrix2D(
          itemCount: itemsInCurrentPage,
          itemBuilder: (context, index, layer) {
            if (pageNum * rows * columns + index >= itemCount) {
              return Container();
            }
            return itemBuilder(
              context,
              pageNum * rows * columns + index,
              layer,
            );
          },
          rows: rows,
          columns: columns,
          layers: layers,
        );
      },
    );
  }
}