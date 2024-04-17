import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key, this.collectionId});
  final int? collectionId;
  @override
  Widget build(BuildContext context) {
    return CameraService(
      collectionId: collectionId,
      onReceiveCapturedMedia: onReceiveCapturedMedia,
      onDone: () {
        if (context.mounted) {
          if (context.canPop()) {
            context.pop();
          }
        }
      },
    );
  }
}
