import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared_media/wizard_page.dart';

enum HandlerStates { normal, select, selected, processing }

class UniversalMediaHandler extends ConsumerStatefulWidget {
  const UniversalMediaHandler({
    required this.galleryMap,
    required this.identifier,
    required this.onDelete,
    super.key,
  });
  final String identifier;

  final List<GalleryGroup<CLMedia>> galleryMap;

  final Future<bool> Function(List<CLMedia> media) onDelete;

  @override
  ConsumerState<UniversalMediaHandler> createState() =>
      UniversalMediaHandlerState();
}

class UniversalMediaHandlerState extends ConsumerState<UniversalMediaHandler> {
  bool keep = false;
  Future<bool> onKeep() async {
    keep = true;
    setState(() {});
    return true;
  }

  Future<bool> onDelete() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MediaViewNormal(
      onKeepAll: () async {
        return false;
      },
      onDeleteAll: () async {
        return false;
      },
      onSelectMode: () async {
        return false;
      },
      option3: const CLMenuItem(icon: Icons.abc, title: 'Select'),
      child: CLGalleryCore0<CLMedia>(
        key: ValueKey(widget.identifier),
        items: widget.galleryMap,
        itemBuilder: (
          context,
          item,
        ) =>
            Hero(
          tag: '${widget.identifier} /item/${item.id}',
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: PreviewService(
              media: item,
              keepAspectRatio: false,
            ),
          ),
        ),
        columns: 3,
      ),
    );
  }
}

class MediaViewNormal extends ConsumerWidget {
  const MediaViewNormal({
    required this.onKeepAll,
    required this.onDeleteAll,
    required this.onSelectMode,
    required this.child,
    this.option3,
    super.key,
  });
  final Future<bool?> Function()? onKeepAll;
  final Future<bool?> Function()? onDeleteAll;
  final Future<bool?> Function()? onSelectMode;
  final Widget child;
  final CLMenuItem? option3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SharedMediaWizard.buildWizard(
        context,
        ref,
        title: 'Unsaved',
        message: 'You may keep or delete all the media or enter select Mode',
        onCancel: () => CLPopScreen.onPop(context),
        option1: CLMenuItem(
          title: 'Keep All',
          icon: Icons.save,
          onTap: onKeepAll,
        ),
        option2: CLMenuItem(
          title: 'Delete All',
          icon: Icons.delete,
          onTap: onDeleteAll,
        ),
        option3: option3,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: child,
        ),
      ),
    );
  }
}
