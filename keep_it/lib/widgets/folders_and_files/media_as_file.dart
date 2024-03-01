import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../wrap_standard_quick_menu.dart';

class MediaAsFile extends ConsumerWidget {
  const MediaAsFile({
    required this.media,
    required this.quickMenuScopeKey,
    super.key,
  });
  final CLMedia media;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDBManager(
      builder: (dbManager) {
        return WrapStandardQuickMenu(
          quickMenuScopeKey: quickMenuScopeKey,
          onDelete: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  alignment: Alignment.center,
                  title: const Text('Confirm Delete'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 200,
                        child: CLMediaPreview(
                          media: media,
                        ),
                      ),
                      CLText.large(
                        'Are you sure you want to delete '
                        'this ${media.type.name}?',
                      ),
                    ],
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
              await dbManager.deleteMedia(media);
            }
            return confirmed ?? false;
          },
          onTap: () async {
            unawaited(
              context.push('/item/${media.collectionId}/${media.id}'),
            );
            return true;
          },
          child: CLMediaPreview(
            media: media,
            keepAspectRatio: false,
          ),
        );
      },
    );
  }
}
