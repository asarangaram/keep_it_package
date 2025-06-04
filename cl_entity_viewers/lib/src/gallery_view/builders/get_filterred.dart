import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/viewer_entity_mixin.dart';
import '../models/tab_identifier.dart';
import '../providers/media_filters.dart' show filterredMediaProvider;

class GetFilterred extends ConsumerWidget {
  const GetFilterred(
      {super.key,
      required this.viewIdentifier,
      required this.candidates,
      required this.builder,
      this.isDisabled = false});
  final bool isDisabled;
  final ViewIdentifier viewIdentifier;
  final List<ViewerEntityMixin> candidates;
  final Widget Function(List<ViewerEntityMixin> filterred) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ViewerEntityMixin> filterred;
    if (isDisabled) {
      filterred = candidates;
    } else {
      filterred = ref
          .watch(filterredMediaProvider(MapEntry(viewIdentifier, candidates)));
    }
    return builder(filterred);
  }
}
