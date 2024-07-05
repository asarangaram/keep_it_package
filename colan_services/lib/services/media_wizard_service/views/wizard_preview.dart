import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../../media_view_service/media_view_service.dart';
import '../../media_view_service/models/action_control.dart';
import '../../preview_service/view/preview.dart';
import '../models/types.dart';
import '../providers/gallery_group_provider.dart';
import '../providers/media_provider.dart';

class WizardPreview extends ConsumerStatefulWidget {
  const WizardPreview({
    required this.type,
    required this.onSelectionChanged,
    required this.freezeView,
    super.key,
  });
  final MediaSourceType type;
  final void Function(List<CLMedia>)? onSelectionChanged;
  final bool freezeView;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WizardPreviewState();
}

class _WizardPreviewState extends ConsumerState<WizardPreview> {
  CLMedia? previewItem;

  MediaSourceType get type => widget.type;
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

    return GetMediaMultiple(
      idList: media0.entries.map((e) => e.id!).toList(),
      buildOnData: (media) {
        /* if (media.length == 1) {
          return MediaViewService(
            media: media[0],
            parentIdentifier: type.identifier,
            actionControl: ActionControl.editOnly(),
          );
        } */
        final galleryMap = ref.watch(singleGroupItemProvider(media));
        return CLGalleryCore<CLMedia>(
          key: ValueKey(type.identifier),
          items: galleryMap,
          itemBuilder: (
            context,
            item,
          ) =>
              Hero(
            tag: '${type.identifier} /item/${item.id}',
            child: GestureDetector(
              onTap: () {
                context.push('/item_view/${item.id}');
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: PreviewService(
                  media: item,
                  keepAspectRatio: false,
                ),
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

class ShowMedia extends ConsumerWidget {
  const ShowMedia({required this.media, required this.type, super.key});
  final CLMedia media;
  final MediaSourceType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: CLBackground(
        child: MediaViewService(
          media: media,
          parentIdentifier: type.identifier,
          actionControl: ActionControl.editOnly(),
        ),
      ),
    );
  }
}
