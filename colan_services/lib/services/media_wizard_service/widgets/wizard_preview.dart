import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

import '../../../internal/entity_grid/gallery_view.dart';
import '../../basic_page_service/widgets/cl_error_view.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import '../../media_view_service/media_view_service1.dart';

class WizardPreview extends ConsumerStatefulWidget {
  const WizardPreview({
    required this.parentIdentifier,
    required this.type,
    required this.onSelectionChanged,
    required this.freezeView,
    super.key,
  });
  final UniversalMediaSource type;
  final void Function(List<CLMedia>)? onSelectionChanged;
  final bool freezeView;
  final String parentIdentifier;

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
      viewIdentifier: ViewIdentifier(
        parentID: widget.parentIdentifier,
        viewId: type.name,
      ),
      emptyWidget: const CLText.large('Nothing to show here'),
      entities: media0.entries,
      numColumns: 3,
      viewableAsCollection: false,
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GalleryView',
      ),
      errorBuilder: errorBuilder,
      selectionActionsBuilder: null,
      onSelectionChanged: onSelectionChanged == null
          ? null
          : (items) =>
              onSelectionChanged?.call(items.map((e) => e as CLMedia).toList()),
      itemBuilder: (context, item) {
        return GestureDetector(
          /* onTap: () async {
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
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: MediaViewService1.preview(
              item as CLMedia,
              parentIdentifier: type.identifier,
            ),
          ),
        );
      },
    );
  }
}
