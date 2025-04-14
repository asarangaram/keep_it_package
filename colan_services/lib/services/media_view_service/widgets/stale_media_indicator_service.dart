import 'package:colan_services/services/media_wizard_service/media_wizard_service.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

class StaleMediaIndicatorService extends ConsumerWidget {
  const StaleMediaIndicatorService({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStaleMedia(
      errorBuilder: (_) => const SizedBox.shrink(),
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetStaleMedia',
      ),
      builder: (staleMedia) {
        if (staleMedia.isEmpty) return const SizedBox.shrink();
        return BannerView(
          staleMediaCount: staleMedia.length,
          onTap: () => MediaWizardService.openWizard(
            context,
            ref,
            CLSharedMedia(
              entries: staleMedia,
              type: UniversalMediaSource.unclassified,
            ),
          ),
        );
      },
    );
  }
}
