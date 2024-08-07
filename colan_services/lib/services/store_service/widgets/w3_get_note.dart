import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'get_store.dart';
import 'w3_get_from_store.dart';

class GetNote extends ConsumerWidget {
  const GetNote({
    required this.buildOnData,
    required this.id,
    super.key,
  });
  final Widget Function(CLNote? note) buildOnData;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStore(
      builder: (store) {
        final q = store.getQuery(DBQueries.notesByMediaId, parameters: [id])
            as StoreQuery<CLNote>;
        return GetFromStore<CLNote>(
          query: q,
          builder: (data) {
            final note = data.where((e) => e.id == id).firstOrNull;
            return buildOnData(note);
          },
        );
      },
    );
  }
}

class GetNotesByMediaId extends ConsumerWidget {
  const GetNotesByMediaId({
    required this.mediaId,
    required this.buildOnData,
    super.key,
  });
  final int mediaId;
  final Widget Function(List<CLNote> note) buildOnData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStore(
      builder: (store) {
        final q =
            store.getQuery(DBQueries.notesByMediaId, parameters: [mediaId])
                as StoreQuery<CLNote>;
        return GetFromStore<CLNote>(
          query: q,
          builder: buildOnData,
        );
      },
    );
  }
}
