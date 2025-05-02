import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';

import 'package:store/store.dart';

import '../../../models/cl_shared_media.dart';
import '../../basic_page_service/basic_page_service.dart';
import '../../media_view_service/media_viewer/views/media_preview.dart';

class DuplicatePage extends StatelessWidget {
  const DuplicatePage({
    required this.incomingMedia,
    required this.parentIdentifier,
    required this.onDone,
    required this.onCancel,
    required this.storeIdentity,
    super.key,
  });
  final CLSharedMedia incomingMedia;
  final String parentIdentifier;
  final void Function({required CLSharedMedia? mg}) onDone;
  final void Function() onCancel;
  final String storeIdentity;

  @override
  Widget build(BuildContext context) {
    return DuplicatePageStateful(
      storeIdentity: storeIdentity,
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
    required this.storeIdentity,
    super.key,
  });
  final CLSharedMedia incomingMedia;
  final String parentIdentifier;
  final void Function({required CLSharedMedia? mg}) onDone;
  final void Function() onCancel;
  final String storeIdentity;

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
    return GetEntity(
      id: widget.incomingMedia.collection?.id,
      storeIdentity: widget.storeIdentity,
      errorBuilder: (_, __) {
        throw UnimplementedError('errorBuilder');
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetAllCollection',
      ),
      builder: (newCollection) {
        final collectionLablel = newCollection?.data.label != null
            ? '"${newCollection?.data.label}"'
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
                      mg: await currentMedia.mergeMismatch(),
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
                    parentIdentifier: widget.parentIdentifier,
                    storeIdentity: widget.storeIdentity,
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
    required this.storeIdentity,
    required this.parentIdentifier,
    required this.onRemove,
    super.key,
  });

  final CLSharedMedia media;
  final String parentIdentifier;
  final String storeIdentity;

  final void Function(StoreEntity media) onRemove;

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

                return GetEntity(
                  id: m.parentId,
                  storeIdentity: storeIdentity,
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
                                  parentIdentifier: parentIdentifier,
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
