import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import 'label_viewer.dart';
import 'edit_collection_description.dart';
import 'pick_collection.dart';
import 'pick_tags.dart';

class CreateCollectionWizard extends StatefulWidget {
  const CreateCollectionWizard({
    required this.onDone,
    super.key,
  });

  final void Function({
    required Collection collection,
    required List<Tag> tags,
  }) onDone;

  @override
  State<StatefulWidget> createState() => PickCollectionState();
}

class PickCollectionState extends State<CreateCollectionWizard> {
  bool onEditLabel = true;
  Collection? collection;
  List<Tag>? selectedTags;
  late bool hasDescription;

  @override
  void initState() {
    collection = null;
    selectedTags = null;
    hasDescription = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (collection == null || onEditLabel) {
      return LoadTags(
        collectionId: collection?.id,
        buildOnData: (currTags) {
          return PickCollection(
            collection: collection,
            onDone: (collection) {
              if (collection.id != null) {
                widget.onDone(collection: collection, tags: currTags.entries);
                hasDescription = true;
              }
              setState(() {
                onEditLabel = false;
                this.collection = collection;
                selectedTags = currTags.entries;
              });
            },
          );
        },
      );
    } else if (!hasDescription) {
      return Column(
        children: [
          LabelViewer(
            label: 'Collection: ${collection!.label}',
            icon: MdiIcons.pencil,
            onTap: () {
              setState(() {
                onEditLabel = true;
              });
            },
          ),
          Flexible(
            child: EditCollectionDescription(
              collection: collection!,
              onDone: (collection) {
                setState(() {
                  this.collection = collection;
                  hasDescription = true;
                });
              },
            ),
          ),
        ],
      );
    } else if (selectedTags == null) {
      return Column(
        children: [
          LabelViewer(
            label: 'Collection: ${collection!.label}',
            icon: MdiIcons.pencil,
            onTap: () {
              setState(() {
                onEditLabel = true;
                hasDescription = false;
              });
            },
          ),
          Flexible(
            child: PickTags(
              collection: collection!,
              onDone: (tags) {
                widget.onDone(collection: collection!, tags: tags);
              },
            ),
          ),
        ],
      );
    } else {
      return const Center(child: CLLoadingView(message: 'Saving...'));
    }
  }
}
