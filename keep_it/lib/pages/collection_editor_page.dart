import 'package:flutter/material.dart';

class CollectionEditorPage extends StatelessWidget {
  const CollectionEditorPage({
    required this.collectionId,
    super.key,
  });

  final int collectionId;

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError('This page needs proper implementation');
    /* 
    FullscreenLayout
    return SizedBox(
      width: min(MediaQuery.of(context).size.width, 450),
      child: CollectionEditor(
        collectionId: collectionId,
        onSubmit: (collection, tags) {},
        onCancel: () {
          if (context.canPop()) {
            context.pop();
          }
        },
      ),
    ); */
  }
}
