import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'wizard_page.dart';

class DuplicatePage extends WizardPageOld {
  const DuplicatePage({
    required super.incomingMedia,
    required super.onDone,
    required super.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DuplicatePageStateful(
      incomingMedia: super.incomingMedia,
      onDone: super.onDone,
      onCancel: super.onCancel,
    );
  }
}

class DuplicatePageStateful extends ConsumerStatefulWidget {
  const DuplicatePageStateful({
    required this.incomingMedia,
    required this.onDone,
    required this.onCancel,
    super.key,
  });
  final CLMediaInfoGroup incomingMedia;
  final void Function({required CLMediaInfoGroup? mg}) onDone;
  final void Function() onCancel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DuplicatePageStatefulState();
}

class _DuplicatePageStatefulState extends ConsumerState<DuplicatePageStateful> {
  late CLMediaInfoGroup currentMedia;

  @override
  void initState() {
    currentMedia = widget.incomingMedia;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadCollections(
      buildOnData: (Collections collections) {
        final newCollection = collections.entries
            .where((e) => e.id == widget.incomingMedia.targetID)
            .firstOrNull;
        final collectionLablel = newCollection?.label != null
            ? '"${newCollection?.label}"'
            : 'a new collection';
        return Padding(
          padding: const EdgeInsets.all(8),
          child: WizardPageOld.buildWizard(
            context,
            ref,
            title: 'Already Imported',
            message: 'Do you want all the above media to be moved '
                'to $collectionLablel or skipped?',
            option1: CLMenuItem(
              icon: Icons.abc,
              title: 'Move',
              onTap: () async {
                widget.onDone(
                  mg: currentMedia.mergeMismatch(),
                );
                return true;
              },
            ),
            option2: CLMenuItem(
              icon: Icons.abc,
              title: 'Skip',
              onTap: () async {
                widget.onDone(
                  mg: currentMedia.removeMismatch(),
                );
                return true;
              },
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /* if (alreadyInSameCollection.isNotEmpty)
                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: ExistsInCollection(
                      media: CLMediaInfoGroup(
                        list: alreadyInSameCollection,
                        targetID: widget.duplicates.targetID,
                      ),
                    ),
                  ), */
                Flexible(
                  child: ExistInDifferentCollection(
                    collections: collections,
                    media: currentMedia,
                    onRemove: (m) {
                      final updated = currentMedia.remove(m);
                      if (updated?.targetMismatch.isEmpty ?? true) {
                        widget.onDone(mg: updated);
                      }
                      setState(() {
                        currentMedia = updated!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ExistInDifferentCollection extends StatelessWidget {
  const ExistInDifferentCollection({
    required this.media,
    required this.collections,
    required this.onRemove,
    super.key,
  });

  final CLMediaInfoGroup media;
  final Collections collections;
  final void Function(CLMedia media) onRemove;

  @override
  Widget build(BuildContext context) {
    final duplicates = media.targetMismatch;
    if (duplicates.isEmpty) {
      const Center(
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
                final m = duplicates[index];
                final currCollection = collections.entries
                    .where((e) => e.id == m.collectionId)
                    .first;

                return SizedBox(
                  height: 80,
                  child: Dismissible(
                    key: Key(m.path),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      onRemove(m);
                    },
                    background: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        'Keep the item in "${currCollection.label.trim()}"',
                      ),
                    ),
                    child: Row(
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Hero(
                              tag: m.path,
                              child: CLMediaPreview(
                                media: m,
                                keepAspectRatio: false,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: CLText.standard(
                                'Found in '
                                '"${currCollection.label.trim()}"',
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
            ),
          ),
        ],
      ),
    );
  }
}
