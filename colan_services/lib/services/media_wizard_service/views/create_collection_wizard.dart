import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:store/store.dart';

import 'edit_collection_description.dart';
import 'label_viewer.dart';
import 'pick_collection.dart';

class CreateCollectionWizard extends StatefulWidget {
  const CreateCollectionWizard({
    required this.onDone,
    this.fixedHeight = true,
    super.key,
  });
  final bool fixedHeight;
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
    final Widget child;
    if (collection == null || onEditLabel) {
      child = PickCollection(
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
      child = Column(
        children: [
          LabelViewer(
            label: 'Collection: ${collection!.label}',
            icon: clIcons.editCollectionLabel,
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
      child = const Center(child: CLLoadingView(message: 'Saving...'));
    }
    if (widget.fixedHeight) {
      return SizedBox(
        height: kMinInteractiveDimension * 4,
        child: child,
      );
    }
    return child;
  }
}
