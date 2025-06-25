import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

class MediaTitle extends StatelessWidget {
  const MediaTitle({
    required this.entityAsync,
    super.key,
  });
  final AsyncValue<ViewerEntity?> entityAsync;

  @override
  Widget build(BuildContext context) {
    return GetActiveStore(
        loadingBuilder: () => const CustomListTile(title: 'Keep It'),
        errorBuilder: (e, st) => const CustomListTile(title: 'Keep It'),
        builder: (activeStore) {
          final defaultTitle = CustomListTile(
            title: 'Keep It',
            subTitle: activeStore.label,
          );
          return entityAsync.when(
              loading: () => defaultTitle,
              error: (e, st) => defaultTitle,
              data: (entity) {
                return Column(
                  children: [
                    if (entity == null)
                      defaultTitle
                    else
                      CustomListTile(
                        title: entity.label?.capitalizeFirstLetter() ??
                            'media #${entity.id ?? "New Media"}',
                        subTitle: activeStore.label,
                      ),
                  ],
                );
              });
        });
  }
}

class CustomListTile extends ConsumerWidget {
  const CustomListTile({required this.title, super.key, this.subTitle});
  final String title;
  final String? subTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(
        title,
        style: ShadTheme.of(context).textTheme.h3,
      ),
      subtitle: (subTitle == null)
          ? null
          : Text(
              subTitle!,
              style: ShadTheme.of(context).textTheme.small,
            ),
    );
  }
}
