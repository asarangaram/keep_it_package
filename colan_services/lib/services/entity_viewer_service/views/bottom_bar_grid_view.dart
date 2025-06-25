import 'package:cl_entity_viewers/cl_entity_viewers.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../models/platform_support.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import '../../incoming_media_service/incoming_media_monitor.dart';

class BottomBarGridView extends ConsumerWidget implements PreferredSizeWidget {
  const BottomBarGridView({
    required this.serverId,
    required this.entity,
    super.key,
  });

  final ViewerEntity? entity;
  final String serverId;

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const ServerBar(),
          Row(
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
                      PageManager.of(context)
                          .openCamera(parentId: entity?.id, serverId: serverId);
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ServerBar extends ConsumerWidget {
  const ServerBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showText = ref.watch(serverBarStatusProvider);
    return GetActiveStore(
        errorBuilder: (_, __) => const SizedBox.shrink(),
        loadingBuilder: SizedBox.shrink,
        builder: (activeServer) {
          return ShadBadge(
            padding:
                const EdgeInsets.only(left: 2, right: 2, top: 2, bottom: 2),
            onPressed: () =>
                ref.read(serverBarStatusProvider.notifier).state = !showText,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                const ShadAvatar(
                  'assets/icon/not_on_server.png',
                  // size: const Size.fromRadius(20),
                ),
                if (showText)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(activeServer.label),
                  )
              ],
            ),
          );
        });
  }
}

final serverBarStatusProvider = StateProvider<bool>((ref) {
  return false;
});
