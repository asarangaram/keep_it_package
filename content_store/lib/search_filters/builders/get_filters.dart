import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/filters.dart';
import '../providers/media_filters.dart';

class GetFilters extends ConsumerWidget {
  const GetFilters({
    required this.identifier,
    required this.builder,
    super.key,
  });
  final String identifier;
  final Widget Function(SearchFilters<CLEntity> filters) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(mediaFiltersProvider(identifier));
    return builder(filters);
  }
}
