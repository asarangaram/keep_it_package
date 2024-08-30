import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'providers/universal_media.dart';
import 'views/wizard_preview.dart';

class RecycleBinService extends ConsumerWidget {
  const RecycleBinService({
    required this.type,
    super.key,
  });
  final UniversalMediaSource type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(universalMediaProvider(type));
    if (media.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CLPopScreen.onPop(context);
      });
      return const SizedBox.expand();
    }
    final galleryMap = ref.watch(singleGroupItemProvider(media.entries));
    return CLPopScreen.onSwipe(
      child: SelectAndRestoreMedia(
        media: media,
        type: type,
        galleryMap: galleryMap,
      ),
    );
  }
}

class SelectAndRestoreMedia extends ConsumerStatefulWidget {
  const SelectAndRestoreMedia({
    required this.media,
    required this.type,
    required this.galleryMap,
    super.key,
  });
  final CLSharedMedia media;
  final UniversalMediaSource type;

  final List<GalleryGroup<CLMedia>> galleryMap;

  @override
  ConsumerState<SelectAndRestoreMedia> createState() =>
      SelectAndRestoreMediaState();
}

class SelectAndRestoreMediaState extends ConsumerState<SelectAndRestoreMedia> {
  CLSharedMedia selectedMedia = const CLSharedMedia(entries: []);

  bool keepSelected = false;
  bool isSelectionMode = false;

  CLSharedMedia get candidate => isSelectionMode ? selectedMedia : widget.media;
  bool get hasCandidate => candidate.isNotEmpty;

  String get keepActionLabel => [
        widget.type.keepActionLabel,
        if (isSelectionMode)
          'Selected'
        else
          widget.media.entries.length > 1 ? 'All' : '',
      ].join(' ');
  String get deleteActionLabel => [
        widget.type.deleteActionLabel,
        if (isSelectionMode)
          'Selected'
        else
          widget.media.entries.length > 1 ? 'All' : '',
      ].join(' ');
  String get toggleSelectModeActionLabel => isSelectionMode ? 'Done' : 'Select';

  bool get canSelect => !keepSelected && widget.media.entries.length > 1;
  void onToggleSelectMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currMedia =
        (isSelectionMode ? selectedMedia.entries : widget.media.entries);
    return WizardLayout(
      title: widget.type.label,
      onCancel: () => CLPopScreen.onPop(context),
      actions: [
        if (canSelect)
          CLButtonText.small(
            toggleSelectModeActionLabel,
            onTap: onToggleSelectMode,
          ),
      ],
      wizard: GetStoreManager(
        builder: (theStore) {
          return WizardDialog(
            option1: CLMenuItem(
              title: keepActionLabel,
              icon: Icons.save,
              onTap: hasCandidate
                  ? () async {
                      keepSelected = true;
                      setState(() {});
                      final confirmed =
                          await ConfirmAction.restoreMediaMultiple(
                                context,
                                media: currMedia,
                              ) ??
                              false;
                      if (!confirmed) return confirmed;
                      if (context.mounted) {
                        final res =
                            await theStore.restoreMediaMultiple(currMedia);

                        if (res) {
                          await ref
                              .read(
                                universalMediaProvider(widget.type).notifier,
                              )
                              .remove(candidate.entries);
                          selectedMedia = const CLSharedMedia(entries: []);
                          keepSelected = false;

                          isSelectionMode = false;
                          setState(() {});
                        }
                        return res;
                      }
                      return null;
                    }
                  : null,
            ),
            option2: (widget.type.canDelete)
                ? CLMenuItem(
                    title: deleteActionLabel,
                    icon: Icons.delete,
                    onTap: hasCandidate
                        ? () async {
                            final confirmed = await ConfirmAction
                                    .permanentlyDeleteMediaMultiple(
                                  context,
                                  media: currMedia,
                                ) ??
                                false;
                            if (!confirmed) return confirmed;
                            if (context.mounted) {
                              final res =
                                  await theStore.permanentlyDeleteMediaMultiple(
                                currMedia,
                              );

                              if (res) {
                                await ref
                                    .read(
                                      universalMediaProvider(widget.type)
                                          .notifier,
                                    )
                                    .remove(candidate.entries);
                                selectedMedia =
                                    const CLSharedMedia(entries: []);
                                keepSelected = false;

                                isSelectionMode = false;
                                setState(() {});
                              }

                              return res;
                            }
                            return false;
                          }
                        : null,
                  )
                : null,
          );
        },
      ),
      child: WizardPreview(
        type: widget.type,
        onSelectionChanged: isSelectionMode
            ? (List<CLMedia> items) {
                selectedMedia = selectedMedia.copyWith(entries: items);
                setState(() {});
              }
            : null,
        freezeView: keepSelected,
      ),
    );
  }
}
