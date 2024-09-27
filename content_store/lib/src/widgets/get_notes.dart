import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class GetNotesByMediaId extends ConsumerWidget {
  const GetNotesByMediaId({
    required this.mediaId,
    required this.builder,
    super.key,
  });

  final int mediaId;
  final Widget Function(List<CLMedia> notes) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
