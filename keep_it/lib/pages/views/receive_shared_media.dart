import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/db/db.dart';
import 'package:keep_it/pages/views/receive_shared/save_or_cancel.dart';

import '../../providers/theme.dart';
import 'media_entries_preview.dart';

class ReceiveSharedMedia extends ConsumerStatefulWidget {
  const ReceiveSharedMedia({
    super.key,
    required this.media,
    required this.onDiscard,
    required this.dbManager,
  });
  final Map<String, SupportedMediaType> media;
  final Function() onDiscard;
  final DatabaseManager dbManager;

  @override
  ConsumerState<ReceiveSharedMedia> createState() => _ReceiveSharedMediaState();
}

class _ReceiveSharedMediaState extends ConsumerState<ReceiveSharedMedia> {
  bool isMinimized = true;
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return CLFullscreenBox(
        useSafeArea: true,
        backgroundColor: theme.colorTheme.backgroundColor,
        hasBorder: true,
        child: Stack(
          children: [
            Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Flexible(child: PreviewOfMediaEntries(media: widget.media)),
                    const SelectedTags(),
                    const SizedBox(
                      height: 120,
                    )
                  ],
                )),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SaveOrCancel(
                      onDiscard: widget.onDiscard,
                      onSave: () {},
                    ),
                  ],
                ))
          ],
        ));
  }
}

class SelectedTags extends ConsumerWidget {
  const SelectedTags({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return Center(
      child: CLText.small(
        "No Tags Selected..., select at least one tag to continue.",
        color: theme.colorTheme.errorColor,
      ),
    );
  }
}
