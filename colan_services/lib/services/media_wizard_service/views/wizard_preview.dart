import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../store_service/providers/gallery_group_provider.dart';
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
          Card(
        child: Stack(
          children: [
            Hero(
              tag: '${type.identifier} /item/${item.id}',
              child: GestureDetector(
                onTap: () => TheStore.of(context).openMedia(
                  item.id!,
                  parentIdentifier: type.identifier,
                  actionControl: ActionControl.none(),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: widget.getPreview(item),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 4,
              right: 4,
              child: ColoredBox(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.edit,
                      size: 40,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8),
                    Icon(
                      Icons.delete,
                      size: 40,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      columns: 2,
      onSelectionChanged: onSelectionChanged,
      keepSelected: freezeView,
    );
  }
}
