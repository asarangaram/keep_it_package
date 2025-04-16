import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'w3_get_from_store.dart';

class GetEntities extends ConsumerWidget {
  const GetEntities({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.storeIdentity,
    this.parentId,
    this.isCollection,
    super.key,
  });
  final Widget Function(List<StoreEntity> items) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final String storeIdentity;
  final int? parentId;
  final bool? isCollection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = EntityQuery(
      storeIdentity,
      {
        'isHidden': 0,
        'isDeleted': 0,
        'parentId': parentId,
        if (isCollection != null) 'isCollection': isCollection! ? 1 : 0,
      },
    );

    return GetFromStore(
      query: query,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: builder,
    );
  }
}
