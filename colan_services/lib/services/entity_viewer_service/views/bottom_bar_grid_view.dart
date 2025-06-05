import 'package:cl_entity_viewers/cl_entity_viewers.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../models/platform_support.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import '../../incoming_media_service/incoming_media_monitor.dart';

class BottomBarGridView extends ConsumerWidget implements PreferredSizeWidget {
  const BottomBarGridView({
    required this.entity,
    super.key,
  });

  final ViewerEntityMixin? entity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: (ColanPlatformSupport.isMobilePlatform ? 0 : 8) +
            MediaQuery.of(context).padding.bottom,
        top: 8,
        left: 8,
        right: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ShadButton.ghost(
            child: clIcons.insertItem.iconFormatted(),
            onPressed: () {
              IncomingMediaMonitor.onPickFiles(
                context,
                ref,
                collection: entity,
              );
            },
          ),
          if (ColanPlatformSupport.cameraSupported)
            Align(
              alignment: Alignment.centerRight,
              child: ShadButton.ghost(
                child: clIcons.camera.iconFormatted(),
                onPressed: () {
                  PageManager.of(context).openCamera(
                    parentId: entity?.id,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
