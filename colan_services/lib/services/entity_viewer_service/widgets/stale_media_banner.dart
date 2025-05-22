import 'package:colan_services/internal/cl_banner.dart';
import 'package:colan_services/services/media_wizard_service/media_wizard_service.dart';

import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/cl_shared_media.dart';
import '../../../models/universal_media_source.dart';

class StaleMediaBanner extends CLBanner {
  const StaleMediaBanner({
    required this.storeIdentity,
    super.key,
  });
  final String storeIdentity;
  @override
  String get widgetLabel => 'StaleMediaBanner';

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref, {
    Color? backgroundColor,
    Color? foregroundColor,
    String msg = '',
    void Function()? onTap,
  }) {
    return GetEntities(
      isHidden: true,
      isCollection: false,
      parentId: 0,
      storeIdentity: storeIdentity,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: (staleMedia) {
        return super.build(
          context,
          ref,
          msg: staleMedia.isEmpty
              ? ''
              : 'You have ${staleMedia.length} unclassified media. '
                  'Tap here to show',
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
