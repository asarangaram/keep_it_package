import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

class DeleteMediaPage extends ConsumerWidget {
  const DeleteMediaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const label = 'Deleted';
    const parentIdentifier = 'Deleted Media';
    return MediaHandlerWidget(
      builder: ({required action}) {
        return GetDeletedMedia(
          buildOnData: (media) {
            if (media.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                CLPopScreen.onPop(context);
              });
            }
            return CLPopScreen.onSwipe(
              child: Column(
                children: [
                  Expanded(
                    child: CLSimpleGalleryView<CLMedia>(
                      key: const ValueKey(label),
                      title: 'Deleted Media',
                      itemBuilder: (
                        context,
                        item, {
                        required quickMenuScopeKey,
                      }) =>
                          Hero(
                        tag: '$parentIdentifier /item/${item.id}',
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: PreviewService(
                            media: item,
                            keepAspectRatio: false,
                          ),
                        ),
                      ),
                      galleryMap: ref.watch(singleGroupItemProvider(media)),
                      emptyState: const Center(
                        child: CLText.large(
                          'The medias pinned to show '
                          'in gallery are shown here.',
                        ),
                      ),
                      identifier: 'Pinned Media',
                      columns: 2,
                      selectionActions: (context, items) {
                        return [
                          CLMenuItem(
                            title: 'Restore',
                            icon: MdiIcons.imageMove,
                            onTap: () => action.restoreDeleted(items),
                          ),
                          CLMenuItem(
                            title: 'Delete',
                            icon: Icons.delete,
                            onTap: () => action.delete(items),
                          ),
                        ];
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => action.restoreDeleted(media),
                          label: const CLText.small('Restore All'),
                          icon: Icon(MdiIcons.imageMove),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => action.delete(media),
                          label: const CLText.small('Discard All'),
                          icon: Icon(MdiIcons.delete),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
