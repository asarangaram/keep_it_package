import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../image_view_service/image_view_service.dart';
import '../../notes_service/notes_service.dart';
import '../../preview_service/view/preview.dart';
import '../../video_player_service/providers/show_controls.dart';
import '../../video_player_service/video_player.dart';
import '../models/types.dart';
import '../providers/gallery_group_provider.dart';
import '../providers/media_provider.dart';
import 'media_edit_button.dart';

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
        if (media.length == 1) {
          return ImageViewService(file: File(media[0].path));
        }
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
                showDialog<void>(
                  context: context,
                  builder: (context) {
                    return Dialog.fullscreen(
                      backgroundColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: WizardLayout(
                          actions: [
                            WizardMediaControl(media: item),
                          ],
                          child: GetMedia(
                            id: item.id!,
                            buildOnData: (mediaLive) => ShowMedia(
                              media: mediaLive!,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
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
  const ShowMedia({required this.media, super.key});
  final CLMedia media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControl = ref.watch(showControlsProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Center(
            child: media.type == CLMediaType.image
                ? ImageViewService(
                    file: File(media.path),
                  )
                : VideoPlayerService.player(
                    media: media,
                    alternate: PreviewService(media: media),
                    autoStart: true,
                    inplaceControl: true,
                  ),
          ),
        ),
        if (showControl.showNotes)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: NotesService(media: media),
          ),
        SizedBox(
          height: kMinInteractiveDimension,
          child: CLButtonText.standard(
            'Done',
            onTap: Navigator.of(context).pop,
          ),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
