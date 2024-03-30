import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/p1_app_settings.dart';

import 'async_widgets.dart';

class GetAppSettings extends ConsumerWidget {
  const GetAppSettings({required this.builder, super.key});
  final Widget Function(AppSettings settings) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShowAsyncValue<AppSettings>(
      ref.watch(appSettingsProvider),
      builder: builder,
    );
  }
}
