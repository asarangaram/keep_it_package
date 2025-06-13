import 'package:cl_entity_viewers/cl_entity_viewers.dart'
    show MediaThumbnail, ViewerEntities;
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

class ExistInDifferentCollection extends StatelessWidget {
  const ExistInDifferentCollection(
      {required this.onRemove, required this.targetMismatch, super.key});

  final ViewerEntities targetMismatch;

  final void Function(StoreEntity media) onRemove;

  @override
  Widget build(BuildContext context) {
    final duplicates = targetMismatch;
    if (duplicates.isEmpty) {
      return const Center(
        child: CLText.large('Nothing to show here'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CLText.verySmall(
                'Swipe individual items to leave it in the same group.',
                color: Theme.of(context).disabledColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              itemCount: duplicates.length,
              itemBuilder: (BuildContext ctx, index) {
                final m = duplicates.entities[index] as StoreEntity;

                return GetEntity(
                  id: m.parentId,
                  errorBuilder: (_, __) {
                    throw UnimplementedError('errorBuilder');
                  },
                  loadingBuilder: () => CLLoader.widget(
                    debugMessage: 'GetAllCollection',
                  ),
                  builder: (currCollection) {
                    /* final currCollection = collections
                        .where((e) => e.id == m.parentId)
                        .firstOrNull; */
                    final String currCollectionLabel;

                    if (m.data.isDeleted) {
                      currCollectionLabel = 'Deleted Items';
                    } else {
                      currCollectionLabel =
                          currCollection?.data.label ?? 'somethig wrong';
                    }
                    return SizedBox(
                      height: 80,
                      child: Dismissible(
                        key: Key(m.data.md5!),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          onRemove(m);
                        },
                        background: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: AlignmentDirectional.center,
                          child: Text(
                            'Keep the item in "${currCollectionLabel.trim()}"',
                          ),
                        ),
                        child: Row(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: MediaThumbnail(
                                  media: m,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: CLText.standard(
                                    'Found in '
                                    '"${currCollectionLabel.trim()}"',
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
