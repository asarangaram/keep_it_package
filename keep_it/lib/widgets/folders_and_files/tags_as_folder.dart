import 'dart:async';
import 'dart:math';

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
    return GetDBManager(
      builder: (dbManager) {
        return WrapStandardQuickMenu(
          quickMenuScopeKey: quickMenuScopeKey,
          onEdit: () async {
            final updated = await TagEditor.popupDialog(context, tag: tag);
            if (updated != null) {
              /* await dbManager.updateTag(updated); */
              throw UnimplementedError('Wait');
            }
            return true;
          },
          onDelete: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: CLText.large(
                    'Are you sure you want to delete '
                    '"${tag.label}" and its content?',
                  ),
                  actions: [
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          child: const Text('No'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        ElevatedButton(
                          child: const Text('Yes'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
            if (confirmed ?? false) {
              await dbManager.deleteTag(tag);
            }
            return confirmed ?? false;
          },
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
      },
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
    return GetMediaByTagId(
      tagID: tag.id,
      buildOnData: (List<CLMedia>? clMediaList) {
        return CLAspectRationDecorated(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: CLMediaCollage.byMatrixSize(
            clMediaList?.sublist(0, min(4, clMediaList.length)) ?? [],
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
