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
    this.parentId, // parentID = 0 ignores parentId, null is a valid parentId
    this.isCollection, // isCollection = null ignores isCollection
    super.key,
    this.isHidden = false, // isHidden = null ignores isHidden
    this.isDeleted = false, // isDeleted = null ignores isDeleted
  });
  final Widget Function(List<StoreEntity> items) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final String storeIdentity;
  final int? parentId;
  final bool? isCollection;
  final bool? isHidden;
  final bool? isDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = EntityQuery(
      storeIdentity,
      {
        if (isHidden != null) 'isHidden': isHidden! ? 1 : 0,
        if (isDeleted != null) 'isDeleted': isDeleted! ? 1 : 0,
        if (parentId != 0) 'parentId': parentId,
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
