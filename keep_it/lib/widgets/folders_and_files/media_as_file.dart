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
          onMove: () async {
            unawaited(
              context.push(
                '/item_move/${media.collectionId}/${media.id}',
              ),
            );
            return true;
            /* final confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return ConfirmAction(
                  title: 'Confirm delete',
                  message: 'Are you sure you want to move '
                      'this ${media.type.name}?',
                  child: CLMediaPreview(media: media),
                  onConfirm: ({required confirmed}) =>
                      Navigator.of(context).pop(confirmed),
                );
              },
            ); 
            if (confirmed ?? false) {
              unawaited(
                context.push(
                  '/item_move/${media.collectionId}/${media.id}',
                ),
              );
            }
            return confirmed ?? false;*/
          },
          onDelete: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return ConfirmAction(
                  title: 'Confirm delete',
                  message: 'Are you sure you want to delete '
                      'this ${media.type.name}?',
                  child: CLMediaPreview(media: media),
                  onConfirm: ({required confirmed}) =>
                      Navigator.of(context).pop(confirmed),
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

class ConfirmAction extends StatelessWidget {
  const ConfirmAction({
    required this.title,
    required this.message,
    required this.child,
    required this.onConfirm,
    super.key,
  });

  final String title;
  final String message;
  final Widget? child;
  final void Function({
    required bool confirmed,
  }) onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: Alignment.center,
      title: const Text('Confirm Delete'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 200,
            child: child,
          ),
          CLText.large(message),
        ],
      ),
      actions: [
        ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => onConfirm(confirmed: false),
              child: const Text('No'),
            ),
            ElevatedButton(
              child: const Text('Yes'),
              onPressed: () => onConfirm(confirmed: true),
            ),
          ],
        ),
      ],
    );
  }
}
