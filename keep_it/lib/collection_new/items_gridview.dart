import 'dart:io';
import 'dart:math';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import 'missing_preview.dart';
import 'new_collection.dart';

class ItemsGridView extends ConsumerWidget {
  const ItemsGridView(this.items, {super.key});
  final Items items;
  static const crossAxisSpacing = 2.0;
  static const mainAxisSpacing = 2.0;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int limitCount = min(items.entries.length, 7);
    return GridView.builder(
      padding: const EdgeInsets.only(top: 2),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index == limitCount) {
          return CLTile(
            child: CLButtonIcon.large(
              MdiIcons.plus,
              onTap: () async {
                await onPickFiles(context, ref,
                    collectionId: items.collection.id);
              },
            ),
          );
        } else if (index < items.entries.length) {
          if (items.entries[index].previewPath != null) {
            return Image.file(
              File(items.entries[index].previewPath!),
              fit: BoxFit.cover,
            );
          }

          return MissingPreview(media: items.entries[index]);
        }
        return Container();
      },
      itemCount: limitCount + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
    );
  }
}
