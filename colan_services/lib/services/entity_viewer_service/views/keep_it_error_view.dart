import 'package:colan_services/services/entity_viewer_service/widgets/on_swipe.dart';
import 'package:colan_services/services/entity_viewer_service/widgets/when_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class KeepItErrorView extends ConsumerWidget {
  const KeepItErrorView({required this.e, required this.st, super.key});
  final Object e;
  final StackTrace st;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OnSwipe(
      child: Scaffold(
        body: WhenError(
          errorMessage: e.toString(),
        ),
      ),
    );
  }
}
