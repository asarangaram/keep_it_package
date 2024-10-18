import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'get_db_reader.dart';
import 'w3_get_from_store.dart';

class GetNotesByMediaId extends ConsumerWidget {
  const GetNotesByMediaId({
    required this.mediaId,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    super.key,
  });

  final int mediaId;
  final Widget Function(List<CLMedia> notes) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDBReader(
      builder: (dbReader) {
        final q =
            dbReader.getQuery(DBQueries.notesByMediaId, parameters: [mediaId])
                as StoreQuery<CLMedia>;

        return GetFromStore<CLMedia>(
          query: q,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          builder: builder,
        );
      },
    );
  }
}
