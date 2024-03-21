// ignore_for_file: unused_element

import 'dart:async';

import 'package:app_loader/app_loader.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/timeline_view.dart';

class CollectionTimeLinePage extends ConsumerWidget {
  const CollectionTimeLinePage({required this.collectionId, super.key});

  final int collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => GetCollection(
        id: collectionId,
        buildOnData: (collection) => GetMediaByCollectionId(
          collectionId: collectionId,
          buildOnData: (items) => TimeLineView(
            label: collection?.label ?? 'All Media',
            items: items,
            parentIdentifier:
                'Gallery View Media CollectionId: ${collection?.id}',
            onTapMedia: (
              int mediaId, {
              required String parentIdentifier,
            }) async {
              unawaited(
                context.push(
                  '/item/$collectionId/$mediaId?parentIdentifier=$parentIdentifier',
                ),
              );
              return true;
            },
            onPickFiles: () async => onPickFiles(
              context,
              ref,
              collection: collection,
            ),
          ),
        ),
      );
}