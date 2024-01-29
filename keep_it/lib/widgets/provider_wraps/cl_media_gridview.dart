import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/state_providers.dart';

class ProviderWrapCLMediaGridView extends ConsumerWidget {
  const ProviderWrapCLMediaGridView._({
    required this.mediaList,
    this.hCount,
    this.vCount,
    super.key,
    this.childSize,
  });
  factory ProviderWrapCLMediaGridView.byMatrixSize(
    List<CLMedia> mediaList, {
    required int hCount,
    int? vCount,
    Key? key,
  }) {
    return ProviderWrapCLMediaGridView._(
      mediaList: mediaList,
      key: key,
      hCount: hCount,
      vCount: vCount,
    );
  }
  factory ProviderWrapCLMediaGridView.byChildSize(
    List<CLMedia> mediaList, {
    required Size childSize,
    Key? key,
  }) {
    return ProviderWrapCLMediaGridView._(
      mediaList: mediaList,
      childSize: childSize,
      key: key,
    );
  }

  final List<CLMedia> mediaList;
  final int? hCount;
  final int? vCount;

  final Size? childSize;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPreviewSquare = ref.watch(isPreviewSquareProvider);

    return switch (childSize) {
      null => CLMediaGridView.byMatrixSize(
          mediaList,
          hCount: hCount!,
          vCount: vCount,
          keepAspectRatio: !isPreviewSquare,
        ),
      _ => CLMediaGridView.byChildSize(
          mediaList,
          childSize: childSize!,
          keepAspectRatio: !isPreviewSquare,
        )
    };
  }
}
