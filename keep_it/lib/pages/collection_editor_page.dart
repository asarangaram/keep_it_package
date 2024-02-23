import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/editors/collection_editor.dart';

class CollectionEditorPage extends StatelessWidget {
  const CollectionEditorPage({
    required this.collectionId,
    super.key,
  });

  final int collectionId;

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
