import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../context_menu_service/models/context_menu_items.dart';
import '../../../context_menu_service/widgets/pull_down_context_menu.dart';

class CollectionAsFolder extends ConsumerWidget {
  const CollectionAsFolder({
    required this.collection,
    this.onTap,
    this.contextMenu,
    super.key,
  });
  final Collection collection;
  final Future<bool?> Function()? onTap;
  final CLContextMenu? contextMenu;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PullDownContextMenu(
      onTap: onTap,
      contextMenu: contextMenu,
      child: CollectionView.preview(collection),
    );
  }
}
