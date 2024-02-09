import 'dart:async';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/from_store/from_store.dart';
import '../widgets/keepit_grid/keepit_grid.dart';

class CollectionsPage extends ConsumerWidget {
  const CollectionsPage({super.key, this.tagId});
  final int? tagId;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      LoadCollections(tagId: tagId, buildOnData: _CollectionsView.new);
}

class _CollectionsView extends ConsumerStatefulWidget {
  const _CollectionsView(this.collections);
  final Collections collections;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CollectionsViewState();
}

class _CollectionsViewState extends ConsumerState<_CollectionsView> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
