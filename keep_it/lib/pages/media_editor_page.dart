import 'dart:io';

import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

class MediaEditorPage extends StatelessWidget {
  const MediaEditorPage({
    required this.mediaId,
    super.key,
  });
  final int? mediaId;

  @override
  Widget build(BuildContext context) {
    if (mediaId == null) {
      return BasicPageService.message(message: 'No Media Provided');
    }
    return FullscreenLayout(
      hasBackground: false,
      backgroundColor: CLTheme.of(context).colors.editorBackgroundColor,
      child: GetAppSettings(
        builder: (appSettings) {
          return MediaHandlerWidget(
            builder: ({required action}) {
              return GetMedia(
                id: mediaId!,
                buildOnData: (media) {
                  if (media == null) {
                    return BasicPageService.message(
                      message: ' Media not found',
                    );
                  }
                  return MediaEditService(
                    media: media,
                    onCreateNewFile: () async {
                      final fileName =
                          'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
                      final imageFile =
                          '${appSettings.directories.downloadedMedia.path.path}/$fileName';

                      File(imageFile).createSync(recursive: true);
                      return imageFile;
                    },
                    onSave: (file, {required overwrite}) async {
                      if (overwrite) {
                        await action.replaceMedia([media], file);
                      } else {
                        await action.cloneAndReplaceMedia([media], file);
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
