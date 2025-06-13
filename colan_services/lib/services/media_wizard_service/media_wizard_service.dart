import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store_tasks/store_tasks.dart';

import '../basic_page_service/widgets/page_manager.dart';

class MediaWizardService extends ConsumerWidget {
  const MediaWizardService({
    required this.type,
    super.key,
  });
  final String? type;

  static Future<bool?> openWizard(
      BuildContext context, WidgetRef ref, StoreTask storeTask,
      {required String serverId}) async {
    if (storeTask.items.isEmpty) {
      throw Exception('Must have atleast one item!');
    }

    // FIXME
    /* await addMedia(
      context,
      ref,
      media: sharedMedia,
    ); */

    if (context.mounted) {
      //FIXME: May find the return value to return
      await PageManager.of(context)
          .openWizard(storeTask.contentOrigin, serverId: serverId);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MediaWizardService0(
      type: type,
      onCancel: () {
        // Review
        ref.read(reloadProvider.notifier).reload();
        PageManager.of(context).pop();
      },
    );
  }
}
