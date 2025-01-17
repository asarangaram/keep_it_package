import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsMainPage extends ConsumerWidget {
  const SettingsMainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KeepItMainView(
      title: 'Settings',
      backButton: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: CLButtonIcon.small(
          clIcons.pagePop,
          onTap: () => PageManager.of(context, ref).pop(),
        ),
      ),
      popupActionItems: const [],
      child: GetDeletedMedia(
        errorBuilder: (_, __) {
          throw UnimplementedError('errorBuilder');
          // ignore: dead_code
        },
        loadingBuilder: () {
          throw UnimplementedError('loadingBuilder');
          // ignore: dead_code
        },
        builder: (deletedMedia) {
          return ListView(
            children: [
              if (deletedMedia.isNotEmpty)
                ListTile(
                  leading: Icon(clIcons.recycleBin),
                  trailing: IconButton(
                    icon: Icon(clIcons.gotoPage),
                    onPressed: () async {
                      await MediaWizardService.openWizard(
                        context,
                        ref,
                        CLSharedMedia(
                          entries: deletedMedia.entries,
                          type: UniversalMediaSource.deleted,
                        ),
                      );
                    },
                  ),
                  title: Text('Deleted Items (${deletedMedia.entries.length})'),
                ),
              const StorageMonitor(),
              const ServerSettings(),
            ],
          );
        },
      ),
    );
  }
}
