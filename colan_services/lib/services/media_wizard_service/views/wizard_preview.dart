import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../basic_page_service/navigators.dart';
import '../../media_view_service/media_view_service.dart';

import '../../media_view_service/providers/group_view.dart';
import '../providers/universal_media.dart';

class WizardPreview extends ConsumerStatefulWidget {
  const WizardPreview({
    required this.type,
    required this.onSelectionChanged,
    required this.freezeView,
    super.key,
  });
  final UniversalMediaSource type;
  final void Function(List<CLMedia>)? onSelectionChanged;
  final bool freezeView;

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
        CLPopScreen.onPop(context);
      });
      return const SizedBox.expand();
    }

    final galleryMap = ref.watch(groupedItemsProvider(media0.entries));

    return GetDBReader(
      builder: (dbReader) {
        return CLGalleryCore<CLMedia>(
          key: ValueKey(type.identifier),
          items: galleryMap,
          itemBuilder: (
            context,
            item,
          ) =>
              GestureDetector(
            onTap: () async {
              await Navigators.openEditor(
                context,
                ref,
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
            },
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: MediaViewService.preview(
                item,
                parentIdentifier: type.identifier,
              ),
            ),
          ),
          columns: 4,
          onSelectionChanged: onSelectionChanged,
          keepSelected: freezeView,
        );
      },
    );
  }
}
