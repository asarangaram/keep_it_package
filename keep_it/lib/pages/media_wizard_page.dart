import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import '../services/media_wizard_service/media_wizard_service.dart';

class MediaWizardPage extends StatelessWidget {
  const MediaWizardPage({required this.type, super.key});
  final UniversalMediaSource type;

  @override
  Widget build(BuildContext context) {
    return CLPopScreen.onSwipe(
      child: MediaWizardService(
        type: type,
        getPreview: (media) => PreviewService(
          media: media,
          keepAspectRatio: false,
        ),
      ),
    );
  }
}
