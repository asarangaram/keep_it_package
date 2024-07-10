import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:keep_it/widgets/preview.dart';

import '../models/store_manager.dart';

class MediaWizardPage extends StatelessWidget {
  const MediaWizardPage({required this.type, super.key});
  final UniversalMediaSource type;

  @override
  Widget build(BuildContext context) {
    return FullscreenLayout(
      child: CLPopScreen.onSwipe(
        child: MediaHandlerWidget(
          builder: ({required action}) {
            return MediaWizardService(
              type: type,
              action: action,
              getPreview: (media) => Preview(media: media),
            );
          },
        ),
      ),
    );
  }
}
