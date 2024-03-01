import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/m3_db_reader.dart';
import '../models/m3_db_readers.dart';
import 'w3_get_from_store.dart';

class GetMedia extends ConsumerWidget {
  const GetMedia({
    required this.buildOnData,
    required this.id,
    super.key,
  });
  final Widget Function(CLMedia media) buildOnData;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetFromStore<CLMedia>(
      query: (DBReaders.mediaById.sql.copyWith(parameters: [id]))
          as DBReader<CLMedia>,
      builder: (data) {
        final media = data.where((e) => e.id == id).firstOrNull;
        if (media != null) {
          return buildOnData(media);
        }
        throw Exception('Media not found');
      },
    );
  }
}

class GetMediaMultiple extends ConsumerWidget {
  const GetMediaMultiple({
    required this.buildOnData,
    this.collectionId,
    this.tagID,
    super.key,
  });
  final Widget Function(List<CLMedia> items) buildOnData;
  final int? collectionId;
  final int? tagID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (collectionId != null && tagID != null) {
      throw Exception("can't specify both collection ID and tag ID");
    }
    final qid = (collectionId == null)
        ? (tagID == null)
            ? DBReaders.mediaAll
            : DBReaders.mediaByTagId
        : DBReaders.mediaByCollectionId;

    return GetFromStore<CLMedia>(
      query: (qid.sql as DBReader<CLMedia>).copyWith(
        parameters: (collectionId == null)
            ? (tagID == null)
                ? []
                : [tagID]
            : [collectionId],
      ),
      builder: buildOnData,
    );
  }
}