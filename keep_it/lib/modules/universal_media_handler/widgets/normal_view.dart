import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/gallery_group_provider.dart';
import '../../shared_media/wizard_page.dart';

class MediaViewNormal extends ConsumerWidget {
  const MediaViewNormal({
    required this.identifier,
    required this.media,
    required this.onKeepAll,
    required this.onDeleteAll,
    required this.onSwitchMode,
    super.key,
  });
  final Future<bool?> Function()? onKeepAll;
  final Future<bool?> Function()? onDeleteAll;
  final Future<bool?> Function()? onSwitchMode;
  final String identifier;

  final CLSharedMedia media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryMap = ref.watch(singleGroupItemProvider(media.entries));
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SharedMediaWizard.buildWizard(
        context,
        ref,
        title: 'Unsaved',
        message: 'You may keep or delete all the media or enter select Mode',
        onCancel: () => CLPopScreen.onPop(context),
        option1: CLMenuItem(
          title: 'Keep All',
          icon: Icons.save,
          onTap: onKeepAll,
        ),
        option2: CLMenuItem(
          title: 'Delete All',
          icon: Icons.delete,
          onTap: onDeleteAll,
        ),
        option3: CLMenuItem(
          icon: Icons.abc,
          title: 'Select',
          onTap: onSwitchMode,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CLGalleryCore0<CLMedia>(
            key: ValueKey(identifier),
            items: galleryMap,
            itemBuilder: (
              context,
              item,
            ) =>
                Hero(
              tag: '$identifier /item/${item.id}',
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: PreviewService(
                  media: item,
                  keepAspectRatio: false,
                ),
              ),
            ),
            columns: 3,
          ),
        ),
      ),
    );
  }
}
