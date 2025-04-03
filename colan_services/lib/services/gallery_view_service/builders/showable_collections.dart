import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class GetShowableCollectionMultiple extends ConsumerWidget {
  const GetShowableCollectionMultiple({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
    this.queries = DBQueries.mediaAll, // FIXME
  });
  final Widget Function(
    CLMedias collections, {
    required bool isAllAvailable,
  }) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final DBQueries queries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetCollectionMultiple(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      query: DBQueries.mediaAll,
      builder: (collections) {
        return builder(
          collections,
          isAllAvailable: true,
        );
      },
    );
  }
}
