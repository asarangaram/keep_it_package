import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/dialogs.dart';
import '../widgets/from_store/from_store.dart';
import '../widgets/keep_it_main_view.dart';
import 'video_list.dart';

class ItemsView extends ConsumerStatefulWidget {
  const ItemsView({required this.collectionID, super.key});

  final int collectionID;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ItemsViewState();
}

class _ItemsViewState extends ConsumerState<ItemsView> {
  @override
  Widget build(BuildContext context) {
    return LoadItems(
      collectionID: widget.collectionID,
      buildOnData: (Items items) {
        return KeepItMainView(
          title: items.collection.label,
          onPop: () {
            if (context.canPop()) {
              context.pop();
            }
          },
          actionsBuilder: [
            (context, quickMenuScopeKey) => CLButtonIcon.standard(
                  Icons.add,
                  onTap: () => KeepItDialogs.onAddItemsIntoCollection(
                    context,
                    ref,
                    items.collection,
                  ),
                ),
          ],
          pageBuilder: (context, quickMenuScopeKey) {
            return Column(
              children: [
                SizedBox(
                  height: 32,
                  child: CLText.standard(items.collection.description ?? ''),
                ),
                const Divider(
                  height: 1,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: VideoList(
                      media: items.videos,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
/* 
class BuildItem extends StatelessWidget {
  const BuildItem({
    required this.media,
    required this.isScrolling,
    required this.onFocus,
    super.key,
  });

  final CLMedia media;
  final bool isScrolling;

  final void Function()? onFocus;

  @override
  Widget build(BuildContext context) {
    if (!context.mounted) return Container();
    return Hero(
      tag: '/item/${media.collectionId}/${media.id}',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(border: Border.all()),
          child: isScrolling
              ? null
              : switch (media.type) {
                  CLMediaType.video => CLVideoPlayer(
                      path: media.path,
                      isPlayingFullScreen: false,
                      onTapFullScreen: () => context.push(
                        '/item/${media.collectionId}/${media.id}?isFullScreen=1',
                      ),
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                      onFocus: onFocus,
                    ),
                  _ => CLMediaPreview(
                      media: media,
                    ),
                },
        ),
      ),
    );
  }
} */

/* class ItemView extends ConsumerWidget {
  const ItemView({required this.media, super.key});
  final CLMedia media;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (media.type.isFile && !File(media.path).existsSync()) {
      throw Exception('File not found ${media.path}');
    }
    return Card(
      elevation: 8,
      color: Colors.transparent,
      child: File(media.path).existsSync()
          ? switch (media) {
              (final image) when image.type == CLMediaType.image => Image.file(
                  File(image.path),
                ),
              (final video) when video.type == CLMediaType.video =>
                VideoPlayerScreen(
                  path: video.path,
                ),
              _ => throw UnimplementedError(
                  'Not yet implemented',
                )
            }
          : const Text('Media not found'),
    );
  }
} */
