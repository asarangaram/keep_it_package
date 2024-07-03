import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/gallery_group_provider.dart';
import '../../shared_media/wizard_page.dart';

class MediaViewSelect extends ConsumerWidget {
  const MediaViewSelect({
    required this.identifier,
    required this.media,
    required this.onKeepSelected,
    required this.onDeleteSelected,
    required this.onSwitchMode,
    required this.hasSelection,
    required this.keepSelected,
    required this.onSelectionChanged,
    super.key,
  });
  final Future<bool?> Function()? onKeepSelected;
  final Future<bool?> Function()? onDeleteSelected;
  final Future<bool?> Function()? onSwitchMode;
  final String identifier;
  final CLSharedMedia media;
  final bool hasSelection;
  final bool keepSelected;
  final void Function(List<CLMedia> items) onSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryMap = ref.watch(singleGroupItemProvider(media.entries));
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SharedMediaWizard.buildWizard(
        context,
        ref,
        title: 'Unsaved',
        message: !hasSelection
            ? 'Select Media to proceed'
            : 'Do you want to keep the selected media or delete ?',
        onCancel: () => CLPopScreen.onPop(context),
        option1: CLMenuItem(
          title: 'Keep Selected',
          icon: Icons.save,
          onTap: onKeepSelected,
        ),
        option2: CLMenuItem(
          title: 'Delete Selected',
          icon: Icons.delete,
          onTap: onDeleteSelected,
        ),
        option3: CLMenuItem(
          icon: Icons.abc,
          title: 'Done',
          onTap: onSwitchMode,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CLGalleryCore1<CLMedia>(
            key: ValueKey(identifier),
            items: galleryMap,
            itemBuilder: (
              context,
              item,
            ) =>
                Hero(
              tag: '$identifier /item/${item.id}',
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: PreviewService(
                  media: item,
                  keepAspectRatio: false,
                ),
              ),
            ),
            columns: 3,
            onSelectionChanged: onSelectionChanged,
            keepSelected: keepSelected,
          ),
        ),
      ),
    );
  }
}
