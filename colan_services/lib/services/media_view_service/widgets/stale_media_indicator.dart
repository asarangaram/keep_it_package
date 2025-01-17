import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../incoming_media_service/models/cl_shared_media.dart';
import '../../media_wizard_service/media_wizard_service.dart';

class StaleMediaIndicatorService extends ConsumerWidget {
  const StaleMediaIndicatorService({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStaleMedia(
      errorBuilder: (p0, p1) => const SizedBox.shrink(),
      loadingBuilder: () => const SizedBox.shrink(),
      builder: (staleMedia) {
        if (staleMedia.isEmpty) return const SizedBox.shrink();
        return CLStaleMediaIndicatorView(
          staleMediaCount: staleMedia.entries.length,
          onTap: () => MediaWizardService.openWizard(
            context,
            ref,
            CLSharedMedia(
              entries: staleMedia.entries,
              type: UniversalMediaSource.unclassified,
            ),
          ),
        );
      },
    );
  }
}
