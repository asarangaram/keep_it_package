import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/from_store/load_items.dart';

class ItemPage extends ConsumerWidget {
  const ItemPage({required this.id, required this.collectionId, super.key});
  final int collectionId;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoadItems(
      collectionID: collectionId,
      buildOnData: (Items items) {
        final media = items.entries.where((e) => e.id == id).first;
        return Stack(
          children: [
            CLMediaView(
              media: media,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withAlpha(192), // Color for the circular container
                ),
                child: CLButtonIcon.small(
                  Icons.close,
                  color:
                      Theme.of(context).colorScheme.background.withAlpha(192),
                  onTap: context.canPop() ? context.pop : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
