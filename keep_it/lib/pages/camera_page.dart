import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key, this.collectionId});
  final int? collectionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStoreManager(
      builder: (theStore) {
        return GetCollection(
          id: collectionId,
          buildOnData: (Collection? collection) {
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
              onNewMedia: (path, {required isVideo}) {
                return theStore.newImageOrVideo(
                  path,
                  isVideo: isVideo,
                  collection: collection,
                );
              },
              onDone: (mediaList) async {
                await TheStore.of(context).openWizard(
                  context,
                  mediaList,
                  UniversalMediaSource.captured,
                  collection: collection,
                );

                if (context.mounted) {
                  await CLPopScreen.onPop(context);
                }
              },
            );
          },
        );
      },
    );
  }
}
