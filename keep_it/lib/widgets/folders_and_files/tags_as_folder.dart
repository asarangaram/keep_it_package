import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_it/widgets/editors/tag_editor.dart';
import 'package:store/store.dart';

import '../wrap_standard_quick_menu.dart';

class TagAsFolder extends ConsumerWidget {
  const TagAsFolder({
    required this.tag,
    required this.quickMenuScopeKey,
    super.key,
  });
  final Tag tag;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WrapStandardQuickMenu(
      quickMenuScopeKey: quickMenuScopeKey,
      onEdit: () async {
        final updated = await TagEditor.popupDialog(context, tag: tag);
        if (updated != null) {
          await ref.read(dbUpdaterNotifierProvider.notifier).upsertTag(updated);
        }
        return true;
      },
      /* onDelete: () async {
        // delete all the items in the tag !!
        await ref.read(tagsProvider(null).notifier).deleteTag(tag);
        return true;
      }, */
      onTap: () async {
        unawaited(
          context.push(
            '/collections/${tag.id}',
          ),
        );
        return true;
      },
      child: Column(
        children: [
          Flexible(
            child: PreviewGenerator(
              tag: tag,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              tag.label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewGenerator extends StatelessWidget {
  const PreviewGenerator({
    required this.tag,
    super.key,
  });
  final Tag tag;

  @override
  Widget build(BuildContext context) {
    return LoadItemsInTag(
      id: tag.id!,
      limit: 4,
      buildOnData: (List<CLMedia>? clMediaList) {
        return CLAspectRationDecorated(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: CLMediaCollage.byMatrixSize(
            clMediaList ?? [],
            hCount: 2,
            vCount: 2,
            itemBuilder: (context, index) => CLMediaPreview(
              media: clMediaList![index],
              keepAspectRatio: false,
            ),
            whenNopreview: CLText.veryLarge(tag.label.characters.first),
          ),
        );
      },
    );
  }
}
