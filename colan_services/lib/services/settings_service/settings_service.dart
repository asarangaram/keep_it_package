import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

class SettingsService extends ConsumerWidget {
  const SettingsService({
    required this.storeIdentity,
    super.key,
  });
  final String storeIdentity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KeepItMainView(
      title: 'Settings',
      backButton: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: CLButtonIcon.small(
          clIcons.pagePop,
          onTap: () => PageManager.of(context).pop(),
        ),
      ),
      popupActionItems: const [],
      child: GetEntities(
        isDeleted: true,
        isHidden: null,
        parentId: 0,
        storeIdentity: storeIdentity,
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
                  leading: Icon(clIcons.recycleBin),
                  trailing: IconButton(
                    icon: Icon(clIcons.gotoPage),
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
