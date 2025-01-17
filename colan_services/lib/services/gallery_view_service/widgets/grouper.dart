import 'package:flutter/material.dart';
import 'package:store/store.dart' show CLEntity, GalleryGroupCLEntity;

class GetGroupedMedia extends StatelessWidget {
  const GetGroupedMedia({
    required this.builder,
    required this.incoming,
    required this.columns,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.getGrouped,
    super.key,
  });
  final int columns;
  final List<CLEntity> incoming;

  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final Widget Function(List<GalleryGroupCLEntity<CLEntity>> galleryMap)
      builder;

  final Future<List<GalleryGroupCLEntity<CLEntity>>> Function(
    List<CLEntity> entities,
  ) getGrouped;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getGrouped(incoming),
      builder: (context, snapShot) {
        if (!snapShot.hasData || snapShot.data == null) {
          return loadingBuilder();
        }

        return builder(snapShot.data!);
      },
    );
  }
}
