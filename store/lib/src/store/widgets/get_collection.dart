import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/m3_db_reader.dart';
import '../models/m3_db_readers.dart';
import 'async_widgets.dart';

class GetCollection extends ConsumerWidget {
  const GetCollection({
    required this.buildOnData,
    this.id,
    super.key,
  });
  final Widget Function(Collection? collections) buildOnData;
  final int? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (id == null) {
      return buildOnData(null);
    }
    return DBReaderWidget<Collection>(
      query: (DBReaders.collectionById.sql.copyWith(parameters: [id]))
          as DBReader<Collection>,
      builder: (data) {
        final collection = data.where((e) => e.id == id).firstOrNull;
        return buildOnData(collection);
      },
    );
  }
}

class GetCollectionMultiple extends ConsumerWidget {
  const GetCollectionMultiple({
    required this.buildOnData,
    super.key,
    this.excludeEmpty = false,
    this.tagId,
  });
  final Widget Function(List<Collection> collections) buildOnData;
  final bool excludeEmpty;
  final int? tagId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qid = excludeEmpty
        ? (tagId == null)
            ? DBReaders.collectionsExcludeEmpty
            : DBReaders.collectionsByTagIDExcludeEmpty
        : (tagId == null)
            ? DBReaders.collectionsAll
            : DBReaders.collectionsByTagId;

    return DBReaderWidget<Collection>(
      query: (qid.sql as DBReader<Collection>)
          .copyWith(parameters: (tagId == null) ? [] : [tagId]),
      builder: buildOnData,
    );
  }
}
