import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../basic_page_service.dart';

class CLErrorView extends StatelessWidget {
  const CLErrorView({
    required this.errorMessage,
    super.key,
    this.errorDetails,
    this.onRecover,
  });

  final String errorMessage;
  final String? errorDetails;
  final CLMenuItem? onRecover;

  @override
  Widget build(BuildContext context) {
    return BasicPageService.withNavBar(
      menuItems: [
        if (onRecover != null) onRecover!,
      ],
      message: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CLIcon.veryLarge(
            LucideIcons.folder,
            color: Theme.of(context).colorScheme.error,
          ),
          CLText.large(trim(errorMessage)),
          ...[
            const SizedBox(
              height: 32,
            ),
            if (errorDetails != null)
              Text(
                errorDetails!,
                textAlign: TextAlign.justify,
                style: ShadTheme.of(context).textTheme.muted,
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
              ),
          ],
        ],
      ),
    );
  }

  String trim(String msg) {
    final parts = msg.split(':');
    return parts.last;
  }
}
