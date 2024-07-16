import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key, this.collectionId});
  final int? collectionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            return TheStore.of(context).newMedia(
              path,
              isVideo: isVideo,
              collection: collection,
            );
          },
          onDone: (mediaList) async {
            await TheStore.of(context).openWizard(
              mediaList,
              UniversalMediaSource.captured,
            );

            if (context.mounted) {
              await CLPopScreen.onPop(context);
            }
          },
          getPreview: (media) => PreviewService(media: media),
        );
      },
    );
  }
}
