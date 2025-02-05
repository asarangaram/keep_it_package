import 'package:colan_services/services/media_view_service/widgets/media_preview_service.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

import '../../../internal/entity_grid/gallery_view.dart';
import '../../basic_page_service/widgets/cl_error_view.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import '../../context_menu_service/models/context_menu_items.dart';

class WizardPreview extends ConsumerStatefulWidget {
  const WizardPreview({
    required this.viewIdentifier,
    required this.type,
    required this.onSelectionChanged,
    required this.freezeView,
    super.key,
  });
  final UniversalMediaSource type;
  final void Function(List<CLMedia>)? onSelectionChanged;
  final bool freezeView;

  final ViewIdentifier viewIdentifier;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WizardPreviewState();
}

class _WizardPreviewState extends ConsumerState<WizardPreview> {
  CLMedia? previewItem;

  UniversalMediaSource get type => widget.type;
  bool get freezeView => widget.freezeView;
  void Function(List<CLMedia>)? get onSelectionChanged =>
      widget.onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final media0 = ref.watch(universalMediaProvider(type));
    if (media0.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PageManager.of(context).pop();
      });
      return const SizedBox.expand();
    }

    Widget errorBuilder(Object e, StackTrace st) =>
        CLErrorView(errorMessage: e.toString());
    return CLEntityGalleryView(
      viewIdentifier: widget.viewIdentifier,
      emptyWidget: const CLText.large('Nothing to show here'),
      entities: media0.entries,
      columns: 3,
      viewableAsCollection: false,
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GalleryView',
      ),
      errorBuilder: errorBuilder,
      bannersBuilder: (context, galleryMap) {
        return [];
      },
      // Wizard don't use context menu
      contextMenuBuilder: (context, list) => CLContextMenu.empty(),
      onSelectionChanged: onSelectionChanged == null
          ? null
          : (items) =>
              onSelectionChanged?.call(items.map((e) => e as CLMedia).toList()),
      itemBuilder: (
        context,
        item, {
        required CLEntity? Function(CLEntity entity)? onGetParent,
        required List<CLEntity>? Function(CLEntity entity)? onGetChildren,
      }) {
        return GetCollection(
          id: (item as CLMedia).collectionId,
          loadingBuilder: () => CLLoader.widget(debugMessage: 'GetCollection'),
          errorBuilder: (p0, p1) =>
              const Center(child: Text('GetCollection Error')),
          builder: (parentCollection) {
            return MediaThumbnail(
              media: item,

              /** onTap: () async {
                await PageManager.of(context).openEditor(
                  item,
                  canDuplicateMedia: false,
                );
            
                /// MEdia might have got updated, better reload and update the
                ///  provider
                if (context.mounted) {
                  final refreshedMedia = CLMedias(
                    await dbReader.getMediasByIDList(
                      media0.entries
                          .where((e) => e.id != null)
                          .map((e) => e.id!)
                          .toList(),
                    ),
                  );
                  ref.read(universalMediaProvider(type).notifier).mediaGroup =
                      media0.copyWith(
                    entries: refreshedMedia.entries,
                  );
                }
              }, */
            );
          },
        );
      },
    );
  }
}
