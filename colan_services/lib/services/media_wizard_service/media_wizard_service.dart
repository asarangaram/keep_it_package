import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/services/media_wizard_service/widgets/select_and_keep_media.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../internal/fullscreen_layout.dart';
import '../../models/cl_shared_media.dart';
import '../../models/universal_media_source.dart';
import '../../providers/universal_media.dart';
import '../basic_page_service/widgets/page_manager.dart';

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

    return FullscreenLayout(
      child: CLEntitiesGridViewScope(
        child: SelectAndKeepMedia(
          viewIdentifier: ViewIdentifier(
            parentID: 'MediaWizardService',
            viewId: type.name,
          ),
          media: media,
          type: type,
        ),
      ),
    );
  }
}
