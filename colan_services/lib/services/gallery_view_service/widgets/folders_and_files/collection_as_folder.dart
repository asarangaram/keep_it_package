import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class CollectionAsFolder extends ConsumerWidget {
  const CollectionAsFolder({
    required this.collection,
    required this.parentIdentifier,
    super.key,
  });
  final Collection collection;

  final String parentIdentifier;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CollectionView.preview(collection);
  }
}
