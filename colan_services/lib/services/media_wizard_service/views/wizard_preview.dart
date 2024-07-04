import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../image_view_service/image_view_service.dart';
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
    final media = ref.watch(universalMediaProvider(type));
    if (media.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CLPopScreen.onPop(context);
      });
      return const SizedBox.expand();
    }
    if (media.entries.length == 1) {
      return ImageViewService(file: File(media.entries[0].path));
    }
    final galleryMap = ref.watch(singleGroupItemProvider(media.entries));
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
                      CLIcon.standard(MdiIcons.pencil),
                    ],
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                    child: ImageViewService(file: File(item.path)),
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
  }
}
