import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/editors/collection_editor.dart';

class CollectionEditorPage extends StatelessWidget {
  const CollectionEditorPage({
    required this.collectionID,
    super.key,
  });

  final int collectionID;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: min(MediaQuery.of(context).size.width, 450),
      child: CollectionEditor(
        collectionID: collectionID,
        onSubmit: (collection, tags) {},
        onCancel: () {
          if (context.canPop()) {
            context.pop();
          }
        },
      ),
    );
  }
}
