import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/services/media_view_service/preview/media_preview_service.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

import '../../basic_page_service/widgets/cl_error_view.dart';
import '../../basic_page_service/widgets/page_manager.dart';

import '../../gallery_view_service/models/entity_actions.dart';
import 'wizard_grid_view.dart';

class WizardPreview extends ConsumerStatefulWidget {
  const WizardPreview({
    required this.viewIdentifier,
    required this.type,
    required this.onSelectionChanged,
    required this.freezeView,
    required this.storeIdentity,
    super.key,
  });
  final UniversalMediaSource type;
  final void Function(List<StoreEntity>)? onSelectionChanged;
  final bool freezeView;

  final ViewIdentifier viewIdentifier;
  final String storeIdentity;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WizardPreviewState();
}

class _WizardPreviewState extends ConsumerState<WizardPreview> {
  StoreEntity? previewItem;

  UniversalMediaSource get type => widget.type;
  bool get freezeView => widget.freezeView;
  void Function(List<StoreEntity>)? get onSelectionChanged =>
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
    return CLGalleryView(
      viewIdentifier: widget.viewIdentifier,
      storeIdentity: widget.storeIdentity,
      emptyWidget: const CLText.large('Nothing to show here'),
      entities: media0.entries,
      columns: 3,
      viewableAsCollection: false,
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GalleryView',
      ),
      errorBuilder: errorBuilder,

      // Wizard don't use context menu
      contextMenuBuilder: (context, list) => EntityActions.empty(),
      onSelectionChanged: onSelectionChanged == null
          ? null
          : (items) => onSelectionChanged
              ?.call(items.map((e) => e as StoreEntity).toList()),
      itemBuilder: (context, item) {
        return MediaThumbnail(
          media: item as StoreEntity,

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
  }
}
