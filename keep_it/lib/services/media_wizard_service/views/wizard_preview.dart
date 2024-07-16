import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../providers/gallery_group_provider.dart';
import '../providers/universal_media.dart';

class WizardPreview extends ConsumerStatefulWidget {
  const WizardPreview({
    required this.type,
    required this.onSelectionChanged,
    required this.freezeView,
    required this.getPreview,
    super.key,
  });
  final UniversalMediaSource type;
  final void Function(List<CLMedia>)? onSelectionChanged;
  final bool freezeView;
  final Widget Function(CLMedia media) getPreview;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WizardPreviewState();
}

class _WizardPreviewState extends ConsumerState<WizardPreview> {
  CLMedia? previewItem;

  UniversalMediaSource get type => widget.type;
  bool get freezeView => widget.freezeView;
  void Function(List<CLMedia>)? get onSelectionChanged =>
      widget.onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final media0 = ref.watch(universalMediaProvider(type));
    if (media0.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CLPopScreen.onPop(context);
      });
      return const SizedBox.expand();
    }

    return GetMediaMultiple(
      idList: media0.entries.map((e) => e.id!).toList(),
      buildOnData: (media) {
        /* if (media.length == 1) {
          return MediaViewService(
            media: media[0],
            parentIdentifier: type.identifier,
            actionControl: ActionControl.editOnly(),
          );
        } */
        final galleryMap = ref.watch(singleGroupItemProvider(media));
        return CLGalleryCore<CLMedia>(
          key: ValueKey(type.identifier),
          items: galleryMap,
          itemBuilder: (
            context,
            item,
          ) =>
              Hero(
            tag: '${type.identifier} /item/${item.id}',
            child: GestureDetector(
              onTap: () => TheStore.of(context).openMedia(
                item.id!,
                parentIdentifier: type.identifier,
                actionControl: ActionControl.editOnly(),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: widget.getPreview(item),
              ),
            ),
          ),
          columns: 4,
          onSelectionChanged: onSelectionChanged,
          keepSelected: freezeView,
        );
      },
    );
  }
}
