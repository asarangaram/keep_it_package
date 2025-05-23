import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetCurrentEntity extends ConsumerWidget {
  const GetCurrentEntity({required this.builder, super.key});
  final Widget Function(ViewerEntityMixin entity) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity =
        ref.watch(mediaViewerUIStateProvider.select((e) => e.currentItem));
    return builder(entity);
  }
}
