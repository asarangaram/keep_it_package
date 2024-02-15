import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CLMediaView extends ConsumerWidget {
  const CLMediaView({required this.media, super.key});
  final CLMedia media;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (media.type.isFile && !File(media.path).existsSync()) {
      return const BrokenImage();
    }

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        // pop on Swipe
        if (details.primaryVelocity! > 0) {
          if (context.canPop()) {
            context.pop();
          }
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        // pop on Swipe
        if (details.primaryVelocity! > 0) {
          if (context.canPop()) {
            context.pop();
          }
        }
      },
      child: SafeArea(
        child: Column(
          children: [
            if (context.canPop() && media.type != CLMediaType.video)
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  height: 32 + 20,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 16, right: 16, bottom: 16),
                    child: CLButtonIcon.small(
                      Icons.close,
                      onTap: context.pop,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Hero(
                tag: '/item/${media.collectionId}/${media.id}',
                child: switch (media.type) {
                  CLMediaType.image =>
                    Center(child: Image.file(File(media.path))),
                  CLMediaType.video => VideoPlayer(media: media),
                  _ => throw UnimplementedError('Not yet implemented')
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
