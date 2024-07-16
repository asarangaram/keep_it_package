import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class Preview extends StatelessWidget {
  const Preview({required this.media, super.key});
  final CLMedia media;

  @override
  Widget build(BuildContext context) {
    return PreviewService(
      media: media,
      getPreviewPath: TheStore.of(context).getPreviewPath,
      keepAspectRatio: false,
    );
  }
}
