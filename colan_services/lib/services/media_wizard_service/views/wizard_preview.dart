import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../store_service/providers/gallery_group_provider.dart';
import '../../store_service/widgets/the_store.dart';
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
    final galleryMap = ref.watch(singleGroupItemProvider(media0.entries));

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
          onTap: () async {
            await TheStore.of(context).openEditor(
              context,
              item,
              canDuplicateMedia: false,
            );

            /// MEdia might have got updated, better reload and update the
            ///  provider
            if (context.mounted) {
              final refreshedMedia =
                  await TheStore.of(context).getMediaMultipleByIds(
                media0.entries
                    .where((e) => e.id != null)
                    .map((e) => e.id!)
                    .toList(),
              );
              ref.read(universalMediaProvider(type).notifier).mediaGroup =
                  media0.copyWith(
                entries: refreshedMedia
                    .where((e) => e != null)
                    .map((e) => e!)
                    .toList(),
              );
            }
          },
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
  }
}
