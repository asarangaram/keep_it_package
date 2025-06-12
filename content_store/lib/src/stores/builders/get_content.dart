import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetContent extends ConsumerWidget {
  const GetContent(
      {required this.id,
      required this.builder,
      required this.errorBuilder,
      required this.loadingBuilder,
      super.key});
  final int? id;
  final Widget Function(ViewerEntity? entity, List<ViewerEntity> children,
      List<ViewerEntity> siblings) builder;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetEntity(
      id: id,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: (entity) {
        return GetEntities(
          parentId: id,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          builder: (children) {
            if (entity == null) {
              return builder(entity, children, []);
            }
            return GetEntities(
                parentId: entity.parentId,
                errorBuilder: errorBuilder,
                loadingBuilder: loadingBuilder,
                builder: (siblings) {
                  return builder(entity, children, siblings);
                });
          },
        );
      },
    );
  }
}
