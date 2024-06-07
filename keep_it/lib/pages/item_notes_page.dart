import 'package:app_loader/app_loader.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:store/store.dart';

import '../modules/notes/input.dart';
import '../widgets/media_view/media_viewer.dart';

class ItemNotesPage extends ConsumerWidget {
  const ItemNotesPage({
    required this.id,
    required this.collectionId,
    required this.parentIdentifier,
    super.key,
  });
  final int collectionId;
  final int id;
  final String parentIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetMedia(
      id: id,
      buildOnData: (media) {
        return FullscreenLayout(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity == null) return;
              // pop on Swipe
              if (details.primaryVelocity! > 0) {
                if (context.canPop()) {
                  context.pop();
                }
              }
            },
            child: Column(
              children: [
                Expanded(
                  child: MediaViewer(
                    media: media,
                    onLockPage: ({required lock}) {},
                    autoStart: false,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(
                    height: 2,
                    thickness: 3,
                    indent: 4,
                    endIndent: 4,
                  ),
                ),
                const Expanded(
                  flex: 5,
                  child: NotesInput(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
