import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../widgets/folder_clip.dart';
import 'media_preview.dart';

class CollectionPreview extends ConsumerWidget {
  const CollectionPreview.preview(
    this.collection, {
    required this.viewIdentifier,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final StoreEntity collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MediaQuery.of(context);
    final borderColor = ShadTheme.of(context).colorScheme.foreground;

    return GetFilters(
      identifier: viewIdentifier.parentID,
      builder: (filters) {
        return GetEntities(
          storeIdentity: collection.store.store.identity,
          parentId: collection.id,
          errorBuilder: (_, __) =>
              throw UnimplementedError('GetMediaByCollectionId'),
          loadingBuilder: () =>
              CLLoader.hide(debugMessage: 'GetMediaByCollectionId'),
          builder: (children) {
            final filterredChildren = children; // FIXME Introduce filter
            return FolderItem(
              name: collection.data.label!,
              borderColor: borderColor,
              avatarAsset: 'assets/icon/not_on_server.png',
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
                              '${filterredChildren.length}/${children.length} matches',
                            ),
                          ),
                        ),
                      ),
                    )
                  : null,
              child: CLMediaCollage.byMatrixSize(
                filterredChildren.length,
                hCount: 3,
                vCount: 3,
                itemBuilder: (context, index) => MediaThumbnail(
                  media: filterredChildren[index],
                ),
                whenNopreview: Center(
                  child: CLText.veryLarge(
                    collection.data.label!.characters.first,
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
    return Stack(
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
          Positioned.fill(
            bottom: 6,
            right: 6,
            child: Align(
              alignment: Alignment.bottomRight,
              child: FractionallySizedBox(
                widthFactor: 0.15,
                heightFactor: 0.15,
                child: ShadAvatar(
                  avatarAsset,
                  // size: const Size.fromRadius(20),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
