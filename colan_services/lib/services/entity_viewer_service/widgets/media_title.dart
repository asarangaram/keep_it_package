import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

class MediaTitle extends StatelessWidget {
  const MediaTitle({
    required this.entity,
    super.key,
  });
  final ViewerEntityMixin? entity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entity == null
              ? 'Keep It'
              : entity!.label?.capitalizeFirstLetter() ??
                  'media #${entity!.id ?? "New Media"}',
          style: entity != null
              ? ShadTheme.of(context).textTheme.h3
              : ShadTheme.of(context).textTheme.h1,
        ),
        if (entity != null)
          Text(
            DateFormat('dd MMM, yyyy')
                .format(entity!.createDate ?? entity!.updatedDate),
            style: ShadTheme.of(context).textTheme.small,
          ),
      ],
    );
  }
}
