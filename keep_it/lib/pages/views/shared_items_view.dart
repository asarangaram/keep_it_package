import 'package:app_loader/app_loader.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/db.dart';
import '../../providers/theme.dart';
import '../../providers/db_manager.dart';

class SharedItemsView extends ConsumerWidget {
  const SharedItemsView({
    super.key,
    required this.media,
    required this.onDiscard,
  });

  final Map<String, SupportedMediaType> media;
  final Function() onDiscard;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageAsync = ref.watch(dbManagerProvider);
    return imageAsync.when(
        data: (DatabaseManager dbManager) => SharedItemsViewInternal(
              media: media,
              onDiscard: onDiscard,
              dbManager: dbManager,
            ),
        loading: () => const CLLoadingView(),
        error: (err, _) => CLErrorView(errorMessage: err.toString()));
  }
}

class SharedItemsViewInternal extends ConsumerWidget {
  const SharedItemsViewInternal({
    super.key,
    required this.media,
    required this.onDiscard,
    required this.dbManager,
  });

  final Map<String, SupportedMediaType> media;
  final Function() onDiscard;
  final DatabaseManager dbManager;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return CLFullscreenBox(
      useSafeArea: true,
      backgroundColor: theme.colorTheme.backgroundColor,
      child: Stack(
        children: [
          Center(
              child: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (final e in media.entries) ...[
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: "${e.value.name.toUpperCase()}: ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: e.key)
                ])),
                const SizedBox(height: 16),
              ],
              TextButton(
                  child: CLText.standard(
                    "Save",
                    color: theme.colorTheme.textColor,
                  ),
                  onPressed: () {
                    // TODO: Implement
                    //onDiscard();
                  })
            ]),
          )),
          Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: onDiscard,
              ))
        ],
      ),
    );
  }
}
