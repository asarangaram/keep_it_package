import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../image_view_service/image_view_service.dart';
import '../../preview_service/view/preview.dart';
import '../models/types.dart';
import '../providers/gallery_group_provider.dart';
import '../providers/media_provider.dart';

class WizardPreview extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: PreviewService(
            media: item,
            keepAspectRatio: false,
          ),
        ),
      ),
      columns: 4,
      onSelectionChanged: onSelectionChanged,
      keepSelected: freezeView,
    );
  }
}
