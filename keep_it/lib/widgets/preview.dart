import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:keep_it/widgets/store_manager.dart';

class Preview extends StatelessWidget {
  const Preview({required this.media, super.key});
  final CLMedia media;

  @override
  Widget build(BuildContext context) {
    return StoreManager(
      builder: ({required storeAction}) {
        return PreviewService(
          media: media,
          getPreviewPath: storeAction.getPreviewPath,
        );
      },
    );
  }
}
