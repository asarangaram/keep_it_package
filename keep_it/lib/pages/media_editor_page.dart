import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'empty_page.dart';

class MediaEditorPage extends StatelessWidget {
  const MediaEditorPage({
    required this.mediaId,
    super.key,
  });
  final int? mediaId;

  @override
  Widget build(BuildContext context) {
    if (mediaId == null) {
      return const EmptyPage(message: 'No Media Provided');
    }
    return FullscreenLayout(
      hasBackground: false,
      backgroundColor: CLTheme.of(context).colors.editorBackgroundColor,
      child: MediaEditService(mediaId: mediaId!),
    );
  }
}
