import 'package:cl_entity_viewers/cl_entity_viewers.dart' show ViewerEntities;
import 'package:colan_services/services/incoming_media_service/extensions/viewer_entities_ext.dart';
import 'package:colan_services/services/incoming_media_service/widgets/exist_in_different_collection.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';

import '../../basic_page_service/basic_page_service.dart';

class DuplicatePage extends StatefulWidget {
  const DuplicatePage(
      {required this.incomingMedia,
      required this.onDone,
      required this.onCancel,
      required this.parentId,
      super.key});
  final ViewerEntities incomingMedia;
  final int? parentId;

  final void Function({required ViewerEntities? mg}) onDone;
  final void Function() onCancel;

  @override
  State<StatefulWidget> createState() => DuplicatePageState();
}

class DuplicatePageState extends State<DuplicatePage> {
  late ViewerEntities currentMedia;

  @override
  void initState() {
    currentMedia = widget.incomingMedia;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (currentMedia.isEmpty) {
      return BasicPageService.message(
        message: 'Should not have seen this.',
      );
    }
    return GetEntity(
      id: widget.parentId,
      errorBuilder: (_, __) {
        throw UnimplementedError('errorBuilder');
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetAllCollection',
      ),
      builder: (newCollection) {
        final collectionLablel = newCollection?.data.label != null
            ? '"${newCollection?.data.label}"'
            : 'a new collection';
        return Padding(
          padding: const EdgeInsets.all(8),
          child: WizardLayout(
            title: 'Already Imported',
            onCancel: widget.onCancel,
            wizard: WizardDialog(
              content: Text('Do you want all the above media to be moved '
                  'to $collectionLablel or skipped?'),
              option1: CLMenuItem(
                icon: clIcons.placeHolder,
                title: 'Move',
                onTap: () async {
                  widget.onDone(
                    mg: await currentMedia.mergeMismatch(widget.parentId),
                  );
                  return true;
                },
              ),
              option2: CLMenuItem(
                icon: clIcons.placeHolder,
                title: 'Skip',
                onTap: () async {
                  widget.onDone(
                    mg: currentMedia.removeMismatch(widget.parentId),
                  );
                  return true;
                },
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ExistInDifferentCollection(
                    targetMismatch:
                        currentMedia.targetMismatch(widget.parentId),
                    onRemove: (m) {
                      final updated = currentMedia.remove(m);
                      if (updated?.targetMismatch(widget.parentId).isEmpty ??
                          true) {
                        widget.onDone(mg: updated);
                        currentMedia = const ViewerEntities([]);
                      } else {
                        currentMedia = updated!;
                      }
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
