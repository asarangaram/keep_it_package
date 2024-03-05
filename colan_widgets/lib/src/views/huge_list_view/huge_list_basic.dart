// ignore_for_file: comment_references, lines_longer_than_80_chars

import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef HugeListViewItemBuilder<T> = Widget Function(
  BuildContext context,
  int index,
);
typedef HugeListViewErrorBuilder = Widget Function(
  BuildContext context,
  dynamic error,
);

class HugeListViewBasic<T> extends ConsumerWidget {
  const HugeListViewBasic({
    required this.totalCount,
    required this.itemBuilder,
    required this.tagPrefix,
    super.key,
    this.waitBuilder,
    this.emptyResultBuilder,
  });

  /// Total number of items in the list.
  final int totalCount;

  /// Called to build an individual item with the specified [index].
  final HugeListViewItemBuilder<T> itemBuilder;

  /// Called to build a progress widget while the whole list is initialized.
  final WidgetBuilder? waitBuilder;

  /// Called to build a widget when the list is empty.
  final WidgetBuilder? emptyResultBuilder;

  final String tagPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (totalCount == -1 && waitBuilder != null) {
      return waitBuilder!(context);
    }
    if (totalCount == 0 && emptyResultBuilder != null) {
      return emptyResultBuilder!(context);
    }

    final scrollController = ref.watch(scrollControllerProvider(tagPrefix));

    return ListView.builder(
      //physics: const BouncingScrollPhysics(),
      physics: const AlwaysScrollableScrollPhysics(),
      controller: scrollController,
      itemCount: max(totalCount, 0),
      itemBuilder: (context, index) {
        return ExcludeSemantics(
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

final scrollControllerProvider =
    StateProvider.family<ScrollController, String>((ref, tagPrefix) {
  final scrollController = ScrollController();
  ref.onDispose(scrollController.dispose);
  return scrollController;
});
