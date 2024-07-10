import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../models/store_manager.dart';
import '../widgets/preview.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key, this.collectionId});
  final int? collectionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FullscreenLayout(
      useSafeArea: false,
      child: MediaHandlerWidget(
        builder: ({required action}) {
          return GetCollection(
            id: collectionId,
            buildOnData: (collection) {
              return CLCameraService(
                onCancel: () => CLPopScreen.onPop(context),
                onError: (String message, {required dynamic error}) async {
                  await ref
                      .read(
                        notificationMessageProvider.notifier,
                      )
                      .push(
                        '$message [$error]',
                      );
                },
                onNewMedia: (path, {required isVideo}) {
                  return action.newMedia(
                    path,
                    isVideo: isVideo,
                    collection: collection,
                  );
                },
                onDone: (mediaList) async {
                  await MediaWizardService.addMedia(
                    context,
                    ref,
                    media: CLSharedMedia(
                      entries: mediaList,
                      type: UniversalMediaSource.captured,
                    ),
                  );

                  if (context.mounted) {
                    await context.push(
                      '/media_wizard?type='
                      '${UniversalMediaSource.captured.name}',
                    );
                  }
                  if (context.mounted) {
                    await CLPopScreen.onPop(context);
                  }
                },
                getPreview: (media) => Preview(media: media),
              );
            },
          );
        },
      ),
    );
  }
}
