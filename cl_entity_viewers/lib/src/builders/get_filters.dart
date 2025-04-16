import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/viewer_entity_mixin.dart';
import '../models/filter/filters.dart';
import '../providers/media_filters.dart';

class GetFilters extends ConsumerWidget {
  const GetFilters({
    required this.identifier,
    required this.builder,
    super.key,
  });
  final String identifier;
  final Widget Function(SearchFilters<ViewerEntityMixin> filters) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(mediaFiltersProvider(identifier));
    return builder(filters);
  }
}
