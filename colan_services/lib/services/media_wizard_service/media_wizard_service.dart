import 'package:colan_services/services/media_wizard_service/widgets/select_and_keep_media.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../internal/fullscreen_layout.dart';
import '../basic_page_service/widgets/page_manager.dart';
import '../incoming_media_service/models/cl_shared_media.dart';
import '../media_view_service/providers/group_view.dart';
import '../notification_services/providers/notify.dart';
import 'providers/universal_media.dart';
import 'widgets/select_and_restore_media.dart';

class MediaWizardService extends ConsumerWidget {
  const MediaWizardService({
    required this.type,
    super.key,
  });
  final UniversalMediaSource type;

  static Future<bool?> openWizard(
    BuildContext context,
    WidgetRef ref,
    CLSharedMedia sharedMedia,
  ) async {
    if (sharedMedia.type == null) {
      return false;
    }
    if (sharedMedia.entries.isEmpty) {
      await ref
          .read(notificationMessageProvider.notifier)
          .push('Nothing to do.');
      return true;
    }

    await addMedia(
      context,
      ref,
      media: sharedMedia,
    );
    if (context.mounted) {
      await PageManager.of(context).openWizard(sharedMedia.type!);
    }

    return true;
  }

  static Future<void> addMedia(
    BuildContext context,
    WidgetRef ref, {
    required CLSharedMedia media,
  }) async {
    ref
        .read(
          universalMediaProvider(
            media.type ?? UniversalMediaSource.unclassified,
          ).notifier,
        )
        .mediaGroup = media;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(universalMediaProvider(type));
    if (media.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PageManager.of(context).pop();
      });
      return const FullscreenLayout(child: SizedBox.expand());
    }

    if (type == UniversalMediaSource.deleted) {
      return FullscreenLayout(
        child: SelectAndRestoreMedia(
          media: media,
          type: type,
        ),
      );
    } else {
      final galleryMap = ref.watch(groupedItemsProvider(media.entries));
      return FullscreenLayout(
        child: SelectAndKeepMedia(
          media: media,
          type: type,
          galleryMap: galleryMap,
        ),
      );
    }
  }
}
