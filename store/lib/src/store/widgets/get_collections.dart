import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../store_signals/store.dart';
import '../../store_signals/subscriptions.dart';

class GetCollectionsByTagId extends StatelessWidget {
  const GetCollectionsByTagId({required this.buildOnData, super.key});
  final Widget Function(Collections collection) buildOnData;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class GetNonEmptyCollectionsByTagId extends StatelessWidget {
  const GetNonEmptyCollectionsByTagId({
    required this.buildOnData,
    super.key,
    this.tagId,
  });
  final Widget Function(List<Collection> collections) buildOnData;
  final int? tagId;

  @override
  Widget build(BuildContext context) {
    final collections = Store.store
        .subscribe<Collection>(
          Subscription<Collection>(
            'collections',
            query: 'SELECT * FROM Collection ' 'ORDER BY LOWER(label) ASC',
            watchTables: {'Collection'},
            fromMap: Collection.fromMap,
          ),
        )
        .watch(context);

    return buildOnData(collections);
  }
}
