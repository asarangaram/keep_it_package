import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key, this.collectionId});
  final int? collectionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStore(
      builder: (theStore) {
        final collection = theStore.getCollectionById(collectionId);
        return CLCameraService(
          parentIdentifier: 'CLCameraService',
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
          onNewMedia: (path, {required isVideo}) async {
            await ref.read(storeCacheProvider.notifier).newImageOrVideo(
                  theStore,
                  path,
                  isVideo: isVideo,
                  collection: collection,
                );
            return null;
          },
          onDone: (mediaList) async {
            await MediaWizardService.openWizard(
              context,
              ref,
              CLSharedMedia(
                entries: mediaList,
                type: UniversalMediaSource.captured,
                collection: collection,
              ),
            );

            if (context.mounted) {
              await CLPopScreen.onPop(context);
            }
          },
        );
      },
    );
  }
}
