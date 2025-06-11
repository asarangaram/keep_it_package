import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../basic_page_service/widgets/cl_error_view.dart';

class WhenEmpty extends ConsumerWidget {
  const WhenEmpty({
    super.key,
    this.onReset,
  });
  final Future<bool?> Function()? onReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CLErrorView(
      errorMessage: 'Nothing to show',
      errorDetails:
          'Import Photos and Videos from the Gallery or using Camera. '
          'Connect to server to view your home collections '
          "using 'Cloud on LAN' service.",
    );
  }
}
