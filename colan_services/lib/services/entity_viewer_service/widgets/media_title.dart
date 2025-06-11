import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

class MediaTitle extends StatelessWidget {
  const MediaTitle({
    required this.entityAsync,
    super.key,
  });
  final AsyncValue<ViewerEntityMixin?> entityAsync;

  @override
  Widget build(BuildContext context) {
    final defaultTitle = Text(
      'Keep It',
      style: ShadTheme.of(context).textTheme.h1,
    );
    return entityAsync.when(
        loading: () => defaultTitle,
        error: (e, st) => defaultTitle,
        data: (entity) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entity == null)
                defaultTitle
              else
                Text(
                  entity.label?.capitalizeFirstLetter() ??
                      'media #${entity.id ?? "New Media"}',
                  style: ShadTheme.of(context).textTheme.h3,
                ),
              if (entity != null)
                Text(
                  DateFormat('dd MMM, yyyy')
                      .format(entity.createDate ?? entity.updatedDate),
                  style: ShadTheme.of(context).textTheme.small,
                ),
            ],
          );
        });
  }
}
