import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaWizardService0 extends ConsumerWidget {
  const MediaWizardService0(
      {required this.type, required this.onCancel, super.key});
  final String? type;
  final void Function() onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text('$type invoked');
  }
}
