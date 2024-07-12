import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/gallery_group_provider.dart';
import 'providers/universal_media.dart';
import 'views/wizard_preview.dart';

class RecycleBinService extends ConsumerWidget {
  const RecycleBinService({
    required this.type,
    required this.getPreview,
    required this.storeAction,
    super.key,
  });
  final UniversalMediaSource type;
  final Widget Function(CLMedia media) getPreview;
  final StoreActions storeAction;

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
        storeAction: storeAction,
        type: type,
        galleryMap: galleryMap,
        getPreview: getPreview,
      ),
    );
  }
}

class SelectAndRestoreMedia extends ConsumerStatefulWidget {
  const SelectAndRestoreMedia({
    required this.media,
    required this.type,
    required this.galleryMap,
    required this.getPreview,
    required this.storeAction,
    super.key,
  });
  final CLSharedMedia media;
  final UniversalMediaSource type;
  final Widget Function(CLMedia media) getPreview;
  final StoreActions storeAction;
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
      wizard: WizardDialog(
        option1: CLMenuItem(
          title: keepActionLabel,
          icon: Icons.save,
          onTap: hasCandidate
              ? () async {
                  keepSelected = true;
                  setState(() {});

                  final res = await ConfirmAction.restoreMediaMultiple(
                    context,
                    media: currMedia,
                    getPreview: widget.getPreview,
                    onConfirm: () => widget.storeAction
                        .restoreDeleted(currMedia, confirmed: true),
                  );

                  await ref
                      .read(
                        universalMediaProvider(widget.type).notifier,
                      )
                      .remove(candidate.entries);
                  selectedMedia = const CLSharedMedia(entries: []);
                  keepSelected = false;

                  isSelectionMode = false;
                  setState(() {});

                  return res;
                }
              : null,
        ),
        option2: (widget.type.canDelete)
            ? CLMenuItem(
                title: deleteActionLabel,
                icon: Icons.delete,
                onTap: hasCandidate
                    ? () async {
                        final res =
                            await ConfirmAction.permanentlyDeleteMediaMultiple(
                          context,
                          media: currMedia,
                          getPreview: widget.getPreview,
                          onConfirm: () => widget.storeAction
                              .delete(currMedia, confirmed: true),
                        );

                        await ref
                            .read(
                              universalMediaProvider(widget.type).notifier,
                            )
                            .remove(candidate.entries);
                        selectedMedia = const CLSharedMedia(entries: []);
                        keepSelected = false;

                        isSelectionMode = false;
                        setState(() {});

                        return res;
                      }
                    : null,
              )
            : null,
      ),
      child: WizardPreview(
        getPreview: widget.getPreview,
        type: widget.type,
        storeAction: widget.storeAction,
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
