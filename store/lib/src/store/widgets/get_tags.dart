import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class GetTagsByCollectionId extends StatelessWidget {
  const GetTagsByCollectionId({
    required this.buildOnData,
    super.key,
    this.collectionId,
  });
  final Widget Function(Tags collection) buildOnData;
  final int? collectionId;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class GetNonEmptyTagsByCollectionId extends StatelessWidget {
  const GetNonEmptyTagsByCollectionId({
    required this.buildOnData,
    super.key,
    this.collectionId,
  });
  final Widget Function(Tags tags) buildOnData;
  final int? collectionId;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
