import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../../internal/folder_clip.dart';
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
          errorBuilder: (_, __) => const BrokenImage(),
          loadingBuilder: () => const GreyShimmer(),
          builder: (children) {
            final filterredChildren = children; // FIXME Introduce filter
            return FolderItem(
              name: collection.data.label!,
              borderColor: borderColor,
              avatarAsset: 'assets/icon/not_on_server.png',
              counter: (filters.isActive || filters.isTextFilterActive)
                  ? Container(
                      margin: const EdgeInsets.all(4),
                      alignment: Alignment.bottomCenter,
                      child: FittedBox(
                        child: ShadBadge(
                          backgroundColor:
                              ShadTheme.of(context).colorScheme.mutedForeground,
                          child: Text(
                            '${filterredChildren.length}/${children.length} matches',
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
                  parentIdentifier: viewIdentifier.parentID,
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
            return FolderWidget(
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
        OverlayWidgets(
          heightFactor: 0.2,
          alignment: Alignment.bottomCenter,
          fit: BoxFit.none,
          child: Container(
            //alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: ShadTheme.of(context)
                .colorScheme
                .foreground
                .withValues(alpha: 0.5),
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ShadTheme.of(context).textTheme.small.copyWith(
                    color: ShadTheme.of(context).colorScheme.background,
                  ),
            ),
          ),
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
