import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/modules/universal_media_handler/widgets/select_view.dart';

import 'normal_view.dart';

enum HandlerState { normal, select, selected, processing }

class UniversalMediaHandler extends ConsumerStatefulWidget {
  const UniversalMediaHandler({
    required this.media,
    required this.identifier,
    required this.onDelete,
    super.key,
  });
  final String identifier;

  final CLSharedMedia media;

  final Future<bool> Function(List<CLMedia> media) onDelete;

  @override
  ConsumerState<UniversalMediaHandler> createState() =>
      UniversalMediaHandlerState();
}

class UniversalMediaHandlerState extends ConsumerState<UniversalMediaHandler> {
  bool isSelectionMode = false;
  bool keepSelected = false;
  CLSharedMedia selectedMedia = const CLSharedMedia(entries: []);

  Future<bool> onSwitchMode() async {
    setState(() {
      isSelectionMode = !isSelectionMode;
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return switch (isSelectionMode) {
      false => MediaViewNormal(
          identifier: widget.identifier,
          media: widget.media,
          onKeepAll: widget.media.isEmpty
              ? null
              : () async {
                  return false;
                },
          onDeleteAll: widget.media.isEmpty
              ? null
              : () async {
                  return false;
                },
          onSwitchMode: onSwitchMode,
        ),
      true => MediaViewSelect(
          identifier: widget.identifier,
          media: widget.media,
          onKeepSelected: selectedMedia.isEmpty
              ? null
              : () async {
                  return false;
                },
          onDeleteSelected: selectedMedia.isEmpty
              ? null
              : () async {
                  return false;
                },
          onSwitchMode: onSwitchMode,
          hasSelection: selectedMedia.entries.isNotEmpty,
          onSelectionChanged: (items) {
            selectedMedia = selectedMedia.copyWith(entries: items);
            setState(() {});
          },
          keepSelected: keepSelected,
        ),
    };
  }
}
