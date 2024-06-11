import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/m3_db_queries.dart';
import '../models/m3_db_query.dart';
import 'w3_get_from_store.dart';

class GetNote extends ConsumerWidget {
  const GetNote({
    required this.buildOnData,
    required this.id,
    super.key,
  });
  final Widget Function(CLNote note) buildOnData;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetFromStore<CLNote>(
      query: (DBQueries.noteById.sql.copyWith(parameters: [id]))
          as DBQuery<CLNote>,
      builder: (data) {
        final note = data.where((e) => e.id == id).firstOrNull;
        if (note != null) {
          return buildOnData(note);
        }
        throw Exception('Media not found');
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
    return GetFromStore<CLNote>(
      query: (DBQueries.notesByMediaId.sql.copyWith(parameters: [mediaId]))
          as DBQuery<CLNote>,
      builder: buildOnData,
    );
  }
}
