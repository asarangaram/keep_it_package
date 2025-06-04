import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:store/store.dart';

import 'edit_collection_description.dart';
import 'label_viewer.dart';
import 'pick_collection.dart';

class CreateCollectionWizard extends StatefulWidget
    implements PreferredSizeWidget {
  const CreateCollectionWizard({
    required this.onDone,
    required this.storeIdentity,
    this.fixedHeight = true,
    super.key,
    this.isValidSuggestion,
  });
  final bool fixedHeight;
  final void Function({
    required StoreEntity collection,
  }) onDone;
  final bool Function(StoreEntity collection)? isValidSuggestion;
  final String storeIdentity;

  @override
  State<StatefulWidget> createState() => PickCollectionState();

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension * 3);
}

class PickCollectionState extends State<CreateCollectionWizard> {
  bool onEditLabel = true;
  StoreEntity? collection;

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
        storeIdentity: widget.storeIdentity,
        collection: collection,
        isValidSuggestion: widget.isValidSuggestion,
        onDone: (collection) {
          if (collection.id != null) {
            widget.onDone(collection: collection);
          }

          hasDescription = collection.id != null;
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
            label: 'Collection: ${collection!.data.label}',
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
      child = Center(
        child: CLLoader.widget(
          message: 'Saving...',
          debugMessage: 'Saving @ PickCollection',
        ),
      );
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
