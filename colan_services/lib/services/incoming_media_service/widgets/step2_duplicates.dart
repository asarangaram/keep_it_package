import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

import '../../basic_page_service/basic_page_service.dart';
import '../../media_view_service/preview/media_preview_service.dart';

class DuplicatePage extends StatelessWidget {
  const DuplicatePage({
    required this.incomingMedia,
    required this.parentIdentifier,
    required this.onDone,
    required this.onCancel,
    super.key,
  });
  final CLSharedMedia incomingMedia;
  final String parentIdentifier;
  final void Function({required CLSharedMedia? mg}) onDone;
  final void Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return DuplicatePageStateful(
      incomingMedia: incomingMedia,
      parentIdentifier: parentIdentifier,
      onDone: onDone,
      onCancel: onCancel,
    );
  }
}

class DuplicatePageStateful extends StatefulWidget {
  const DuplicatePageStateful({
    required this.incomingMedia,
    required this.parentIdentifier,
    required this.onDone,
    required this.onCancel,
    super.key,
  });
  final CLSharedMedia incomingMedia;
  final String parentIdentifier;
  final void Function({required CLSharedMedia? mg}) onDone;
  final void Function() onCancel;

  @override
  State<StatefulWidget> createState() => _DuplicatePageStatefulState();
}

class _DuplicatePageStatefulState extends State<DuplicatePageStateful> {
  late CLSharedMedia currentMedia;

  @override
  void initState() {
    currentMedia = widget.incomingMedia;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (currentMedia.isEmpty) {
      return BasicPageService.nothingToShow(
        message: 'Should not have seen this.',
      );
    }
    return GetCollectionMultiple(
      query: DBQueries.entitiesVisible,
      errorBuilder: (_, __) {
        throw UnimplementedError('errorBuilder');
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetCollectionMultiple',
      ),
      builder: (collections) {
        final newCollection = collections
            .where((e) => e.id == widget.incomingMedia.collection?.id)
            .firstOrNull;
        final collectionLablel = newCollection?.label != null
            ? '"${newCollection?.label}"'
            : 'a new collection';
        return Padding(
          padding: const EdgeInsets.all(8),
          child: WizardLayout(
            title: 'Already Imported',
            onCancel: widget.onCancel,
            wizard: SizedBox(
              height: kMinInteractiveDimension * 3,
              child: WizardDialog(
                content: Text('Do you want all the above media to be moved '
                    'to $collectionLablel or skipped?'),
                option1: CLMenuItem(
                  icon: clIcons.placeHolder,
                  title: 'Move',
                  onTap: () async {
                    widget.onDone(
                      mg: currentMedia.mergeMismatch(),
                    );
                    return true;
                  },
                ),
                option2: CLMenuItem(
                  icon: clIcons.placeHolder,
                  title: 'Skip',
                  onTap: () async {
                    widget.onDone(
                      mg: currentMedia.removeMismatch(),
                    );
                    return true;
                  },
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ExistInDifferentCollection(
                    collections: collections,
                    parentIdentifier: widget.parentIdentifier,
                    media: currentMedia,
                    onRemove: (m) {
                      final updated = currentMedia.remove(m);
                      if (updated?.targetMismatch.isEmpty ?? true) {
                        widget.onDone(mg: updated);
                        currentMedia = const CLSharedMedia(entries: []);
                      } else {
                        currentMedia = updated!;
                      }
                      setState(() {});
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
    required this.parentIdentifier,
    required this.collections,
    required this.onRemove,
    super.key,
  });

  final CLSharedMedia media;
  final String parentIdentifier;
  final List<CLEntity> collections;
  final void Function(CLEntity media) onRemove;

  @override
  Widget build(BuildContext context) {
    final duplicates = media.targetMismatch;
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
                final m = duplicates[index];
                final currCollection =
                    collections.where((e) => e.id == m.parentId).firstOrNull;
                final String currCollectionLabel;

                if (m.isDeleted) {
                  currCollectionLabel = 'Deleted Items';
                } else {
                  currCollectionLabel =
                      currCollection?.label ?? 'somethig wrong';
                }

                return SizedBox(
                  height: 80,
                  child: Dismissible(
                    key: Key(m.md5!),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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
            ),
          ),
        ],
      ),
    );
  }
}
