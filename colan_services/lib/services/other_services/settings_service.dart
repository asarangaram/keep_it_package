import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/cl_shared_media.dart';
import '../../models/universal_media_source.dart';
import '../media_wizard_service/media_wizard_service.dart';

class SettingsService extends ConsumerWidget {
  const SettingsService({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLScaffold(
      topMenu: AppBar(
        title: Text(
          'Settings',
          style: ShadTheme.of(context).textTheme.h1,
        ),
      ),
      bottomMenu: null,
      banners: const [],
      body: GetEntities(
        isDeleted: true,
        isHidden: null,
        parentId: 0,
        errorBuilder: (_, __) {
          throw UnimplementedError('errorBuilder');
        },
        loadingBuilder: () => CLLoader.widget(
          debugMessage: 'GetDeletedMedia',
        ),
        builder: (deletedMedia) {
          return ListView(
            children: [
              if (deletedMedia.isNotEmpty)
                ListTile(
                  leading: clIcons.recycleBin.iconFormatted(),
                  trailing: IconButton(
                    icon: clIcons.gotoPage.iconFormatted(),
                    onPressed: () async {
                      await MediaWizardService.openWizard(
                        context,
                        ref,
                        CLSharedMedia(
                          entries: deletedMedia,
                          type: UniversalMediaSource.deleted,
                        ),
                      );
                    },
                  ),
                  title: Text('Deleted Items (${deletedMedia.length})'),
                ),
              const StorageMonitor(),
            ],
          );
        },
      ),
    );
  }
}
