import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/viewer_entity_mixin.dart';
import '../providers/media_filters.dart' show mediaFiltersProvider;

class GetFilterred extends ConsumerWidget {
  const GetFilterred(
      {super.key,
      required this.candidates,
      required this.builder,
      this.isDisabled = false});
  final bool isDisabled;

  final List<ViewerEntity> candidates;
  final Widget Function(List<ViewerEntity> filterred) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ViewerEntity> filterred;
    if (isDisabled) {
      filterred = candidates;
    } else {
      final mediaFilters = ref.watch(mediaFiltersProvider);
      filterred = mediaFilters.apply(candidates);
    }
    return builder(filterred);
  }
}
