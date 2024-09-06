import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/store_model.dart';

class GetNotesByMediaId extends ConsumerWidget {
  const GetNotesByMediaId({
    required this.mediaId,
    required this.buildOnData,
    super.key,
  });

  final int mediaId;
  final Widget Function(List<CLMedia> notes) buildOnData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}

class GetStore extends ConsumerWidget {
  const GetStore({required this.builder, super.key});
  final Widget Function(StoreModel store) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
