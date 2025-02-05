import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../gallery_view_service/builders/available_media.dart';
import 'widgets/cl_media_collage.dart';
import 'widgets/folder_clip.dart';
import 'widgets/media_preview_service.dart';

class CollectionView extends ConsumerWidget {
  const CollectionView.preview(
    this.collection, {
    required this.viewIdentifier,
    required this.containingMedia,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final Collection collection;
  final List<CLMedia> containingMedia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MediaQuery.of(context);
    final borderColor = collection.hasServerUID
        ? collection.haveItOffline
            ? Colors.blue
            : Colors.green
        : ShadTheme.of(context).colorScheme.foreground;

    return GetFilters(
      identifier: viewIdentifier.parentID,
      builder: (filters) {
        return GetAvailableMediaByCollectionId(
          collectionId: collection.id,
          errorBuilder: (_, __) =>
              throw UnimplementedError('GetMediaByCollectionId'),
          loadingBuilder: () =>
              CLLoader.hide(debugMessage: 'GetMediaByCollectionId'),
          builder: (allMedia) {
            return FolderItem(
              name: collection.label,
              borderColor: borderColor,
              avatarAsset: (collection.serverUID == null)
                  ? 'assets/icon/not_on_server.png'
                  : 'assets/icon/cloud_on_lan_128px_color.png',
              counter: (filters.isActive || filters.isTextFilterActive)
                  ? AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) =>
                          SizeTransition(
                        sizeFactor: animation,
                        child: child,
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        alignment: Alignment.bottomCenter,
                        child: FittedBox(
                          child: ShadBadge(
                            backgroundColor: ShadTheme.of(context)
                                .colorScheme
                                .mutedForeground,
                            child: Text(
                              '${containingMedia.length}/${allMedia.entries.length} matches',
                            ),
                          ),
                        ),
                      ),
                    )
                  : null,
              child: CLMediaCollage.byMatrixSize(
                containingMedia.length,
                hCount: 3,
                vCount: 3,
                itemBuilder: (context, index) => MediaThumbnail(
                  media: containingMedia[index],
                ),
                whenNopreview: Center(
                  child: CLText.veryLarge(
                    collection.label.characters.first,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class FolderItem extends StatelessWidget {
  const FolderItem({
    required this.name,
    required this.child,
    super.key,
    this.borderColor = const Color(0xFFE6B65C),
    this.avatarAsset,
    this.counter,
  });
  final String name;
  final Widget child;
  final Color borderColor;
  final String? avatarAsset;
  final Widget? counter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                LayoutBuilder(
                  builder: (context, constrain) {
                    return LinuxFolderWidget(
                      width: constrain.maxWidth,
                      height: constrain.maxHeight,
                      borderColor: borderColor,
                      child: child,
                    );
                  },
                ),
                if (counter != null)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: counter!,
                  ),
                if (avatarAsset != null)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: ShadAvatar(
                      avatarAsset,
                      size: const Size.fromRadius(20),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
