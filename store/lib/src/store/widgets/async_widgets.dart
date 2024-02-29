// ignore_for_file: lines_longer_than_80_chars

import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/src/store/models/db_query.dart';

import '../providers/db_subscription.dart';

enum QueryId {
  collection,
  tag,
  media,
  collectionsAll,
  collectionsExcludeEmpty,
  collectionsByTagID,
  collectionsByTagIDExcludeEmpty,
  tagsAll,
  tagsByCollectionID,
  tagsAllExcludeEmpty,
  tagsByCollectionIDExcludeEmpty,
  tagsByMediaID,
  mediaAll,
  mediaByCollectionID,
  mediaByTagID,
  mediaByMD5;

  DBQuery<dynamic> get sql => switch (this) {
        collection => DBQuery(
            sql: 'SELECT * FROM Collection WHERE id = ? ',
            triggerOnTables: const {'Collection'},
            fromMap: (map, {pathPrefix}) => Collection.fromMap(map),
          ),
        tag => DBQuery(
            sql: 'SELECT * FROM Tag WHERE id = ? ',
            triggerOnTables: const {'Tag'},
            fromMap: (map, {pathPrefix}) => Tag.fromMap(map),
          ),
        media => DBQuery(
            sql: 'SELECT * FROM Item WHERE id = ?',
            triggerOnTables: const {'Item'},
            fromMap: (map, {pathPrefix}) =>
                CLMedia.fromMap(map, pathPrefix: pathPrefix),
          ),
        collectionsAll => DBQuery(
            sql: 'SELECT * FROM Collection',
            triggerOnTables: const {'Collection'},
            fromMap: (map, {pathPrefix}) => Collection.fromMap(map),
          ),
        collectionsExcludeEmpty => DBQuery(
            sql: 'SELECT DISTINCT Collection.* FROM Collection '
                'JOIN Item ON Collection.id = Item.collection_id;',
            triggerOnTables: const {'Collection', 'Item'},
            fromMap: (map, {pathPrefix}) => Collection.fromMap(map),
          ),
        collectionsByTagID => DBQuery(
            sql: 'SELECT DISTINCT Collection.* '
                'FROM Collection '
                'JOIN TagCollection ON Collection.id = TagCollection.collection_id '
                'WHERE TagCollection.tag_id = :tagId',
            triggerOnTables: const {'Collection', 'Item'},
            fromMap: (map, {pathPrefix}) => Collection.fromMap(map),
          ),
        collectionsByTagIDExcludeEmpty => DBQuery(
            sql: 'SELECT DISTINCT Collection.* '
                'FROM Collection '
                'JOIN Item ON Collection.id = Item.collection_id '
                'JOIN TagCollection ON Collection.id = TagCollection.collection_id '
                'WHERE TagCollection.tag_id = :tagId;',
            triggerOnTables: const {'Collection', 'Item', 'TagCollection'},
            fromMap: (map, {pathPrefix}) => Collection.fromMap(map),
          ),
        QueryId.tagsAll => DBQuery(
            sql: 'SELECT * FROM Tag',
            triggerOnTables: const {'Tag'},
            fromMap: (map, {pathPrefix}) => Tag.fromMap(map),
          ),
        QueryId.tagsAllExcludeEmpty => DBQuery(
            sql: 'SELECT DISTINCT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tag_id '
                'JOIN Collection ON TagCollection.collection_id = Collection.id '
                'JOIN Item ON Collection.id = Item.collection_id ',
            triggerOnTables: const {
              'Tag',
              'TagCollection',
              'Collection',
              'Item',
            },
            fromMap: (map, {pathPrefix}) => Tag.fromMap(map),
          ),
        QueryId.tagsByCollectionID => DBQuery(
            sql: 'SELECT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tag_id '
                'WHERE TagCollection.collection_id = ?',
            triggerOnTables: const {'Tag', 'TagCollection'},
            fromMap: (map, {pathPrefix}) => Tag.fromMap(map),
          ),
        QueryId.tagsByCollectionIDExcludeEmpty => DBQuery(
            sql: 'SELECT DISTINCT Tag.* '
                'FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tag_id '
                'JOIN Collection ON TagCollection.collection_id = Collection.id '
                'JOIN Item ON Collection.id = Item.collection_id '
                'WHERE TagCollection.collection_id = ? ',
            triggerOnTables: const {
              'Tag',
              'TagCollection',
              'Collection',
              'Item',
            },
            fromMap: (map, {pathPrefix}) => Tag.fromMap(map),
          ),
        QueryId.mediaAll => DBQuery(
            sql: 'SELECT * FROM Item',
            triggerOnTables: const {'Item'},
            fromMap: (map, {pathPrefix}) =>
                CLMedia.fromMap(map, pathPrefix: pathPrefix),
          ),
        QueryId.mediaByCollectionID => DBQuery(
            sql: 'SELECT * FROM Item WHERE collection_id = ?',
            triggerOnTables: const {},
            fromMap: (map, {pathPrefix}) =>
                CLMedia.fromMap(map, pathPrefix: pathPrefix),
          ),
        QueryId.mediaByTagID => DBQuery(
            sql: 'SELECT Item.* '
                'FROM Item '
                'JOIN Collection ON Item.collection_id = Collection.id '
                'JOIN TagCollection ON Collection.id = TagCollection.collection_id '
                'WHERE TagCollection.tag_id =? ',
            triggerOnTables: const {},
            fromMap: (map, {pathPrefix}) =>
                CLMedia.fromMap(map, pathPrefix: pathPrefix),
          ),
        QueryId.tagsByMediaID => DBQuery(
            sql: 'SELECT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tag_id '
                'JOIN Item ON TagCollection.collection_id = Item.collection_id '
                'WHERE Item.id = ? ',
            triggerOnTables: const {'Tag', 'TagCollection', 'Item'},
            fromMap: (map, {pathPrefix}) => Tag.fromMap(map),
          ),
        // TODO: Handle this case.
        QueryId.mediaByMD5 => throw UnimplementedError(),
      };
}

class BuildOnQueryMultiple<T> extends ConsumerWidget {
  const BuildOnQueryMultiple(
      {required this.query, required this.builder, super.key});
  final DBQuery<T> query;
  final Widget Function(List<T> results) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dbFetchAndWatch(query));
    return ShowAsyncValue<List<dynamic>>(
      dataAsync,
      builder: (data) {
        return builder(data.map((e) => e as T).toList());
      },
    );
  }
}

class ShowAsyncValue<T> extends ConsumerWidget {
  const ShowAsyncValue(
    this.asyncData, {
    required this.builder,
    super.key,
  });
  final AsyncValue<T> asyncData;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncData.when(
      loading: CLLoadingView.new,
      error: _ShowAsyncError.new,
      data: (data) {
        try {
          return builder(data);
        } catch (e, st) {
          return _ShowAsyncError(e, st);
        }
      },
    );
  }
}

class _ShowAsyncError extends ConsumerWidget {
  const _ShowAsyncError(this.object, this.st, {super.key});
  final Object object;
  final StackTrace st;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLErrorView(errorMessage: object.toString());
  }
}
