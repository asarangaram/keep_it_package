import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key, this.collectionId});
  final int? collectionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FullscreenLayout(
      useSafeArea: false,
      child: CLCameraService(
        collectionId: collectionId,
        onDone: () => CLPopScreen.onPop(context),
        onError: (String message, {required dynamic error}) async {
          await ref
              .read(
                notificationMessageProvider.notifier,
              )
              .push(
                '$message [$error]',
              );
        },
        onReceiveCapturedMedia: () async {
          await context.push('/stale_media');
        },
      ),
    );
  }
}
