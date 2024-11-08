import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extensions/ext_string.dart';
import 'main_header.dart';

class KeepItMainView extends ConsumerStatefulWidget {
  const KeepItMainView({
    required this.pageBuilder,
    required this.backButton,
    super.key,
    this.actionsBuilder,
    this.title,
  });
  final Widget Function(
    BuildContext context,
  ) pageBuilder;
  final List<
      Widget Function(
        BuildContext context,
      )>? actionsBuilder;

  final String? title;
  final Widget? backButton;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => KeepItMainViewState();
}

class KeepItMainViewState extends ConsumerState<KeepItMainView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MainHeader(
            actionsBuilders: widget.actionsBuilder,
            title: widget.title?.uptoLength(15),
            backButton: widget.backButton,
          ),
          Expanded(child: widget.pageBuilder(context)),
        ],
      ),
    );
  }
}
