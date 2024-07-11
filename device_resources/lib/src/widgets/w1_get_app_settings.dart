import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/m1_app_settings.dart';
import '../providers/p1_app_settings.dart';

class GetAppSettings extends ConsumerWidget {
  const GetAppSettings({
    required this.builder,
    super.key,
    required this.errorBuilder,
    required this.loadingBuilder,
  });
  final Widget Function(AppSettings settings) builder;
  final Widget Function(Object object, StackTrace st) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(appSettingsProvider).when(
          loading: loadingBuilder,
          error: errorBuilder,
          data: (data) {
            try {
              return builder(data);
            } catch (e, st) {
              return errorBuilder(e, st);
            }
          },
        );
  }
}
