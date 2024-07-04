import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../image_view_service/image_view_service.dart';
import '../../preview_service/view/preview.dart';
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
                      child: WizardLayout(
                        actions: [
                          MediaEditButton(
                            media: item,
                          ),
                        ],
                        onCancel: () {
                          Navigator.of(context).pop();
                        },
                        child: GetMedia(
                          id: item.id!,
                          buildOnData: (mediaLive) {
                            return ImageViewService(
                              file: File(mediaLive!.path),
                            );
                          },
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
