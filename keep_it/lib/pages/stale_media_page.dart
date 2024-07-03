import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modules/universal_media_handler/models/types.dart';
import '../modules/universal_media_handler/widgets/universal_media_watcher.dart';

class StaleMediaPage extends ConsumerWidget {
  const StaleMediaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const UniversalMediaWatcher(
        type: UniversalMediaTypes.staleMedia,
      );
}
