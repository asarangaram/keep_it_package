import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/services/media_wizard_service/widgets/select_and_keep_media.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

import '../../internal/fullscreen_layout.dart';
import '../basic_page_service/widgets/page_manager.dart';

class MediaWizardService extends ConsumerWidget {
  const MediaWizardService({
    required this.type,
    required this.storeIdentity,
    super.key,
  });
  final UniversalMediaSource type;
  final String storeIdentity;

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
      child: SelectAndKeepMedia(
        viewIdentifier: ViewIdentifier(
          parentID: 'MediaWizardService',
          viewId: type.name,
        ),
        storeIdentity: storeIdentity,
        media: media,
        type: type,
      ),
    );
  }
}
