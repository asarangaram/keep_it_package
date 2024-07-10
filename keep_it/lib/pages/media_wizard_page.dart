import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:keep_it/widgets/preview.dart';

class MediaWizardPage extends StatelessWidget {
  const MediaWizardPage({required this.type, super.key});
  final MediaSourceType type;

  @override
  Widget build(BuildContext context) {
    return FullscreenLayout(
      child: CLPopScreen.onSwipe(
        child: MediaWizardService(
          type: type,
          getPreview: (media) => Preview(media: media),
        ),
      ),
    );
  }
}
