import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'edit_collection_description.dart';
import 'label_viewer.dart';
import 'pick_collection.dart';

class CreateCollectionWizard extends StatefulWidget {
  const CreateCollectionWizard({
    required this.onDone,
    super.key,
  });

  final void Function({
    required Collection collection,
  }) onDone;

  @override
  State<StatefulWidget> createState() => PickCollectionState();
}

class PickCollectionState extends State<CreateCollectionWizard> {
  bool onEditLabel = true;
  Collection? collection;

  late bool hasDescription;

  @override
  void initState() {
    collection = null;

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
      return PickCollection(
        collection: collection,
        onDone: (collection) {
          if (collection.id != null) {
            widget.onDone(collection: collection);
            hasDescription = true;
          }
          setState(() {
            onEditLabel = false;
            this.collection = collection;
          });
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
                widget.onDone(collection: this.collection!);
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
