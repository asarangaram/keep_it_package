import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/notification.dart';
import 'providers/notify.dart';

class NotificationService extends ConsumerStatefulWidget {
  const NotificationService({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationServiceState();
}

class _NotificationServiceState extends ConsumerState<NotificationService> {
  OverlayEntry? entry;
  @override
  Widget build(BuildContext context) {
    final message = ref.watch(
      notificationMessageProvider.select((value) => value.firstOrNull),
    );
    if (message != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showSnackbar(context, ref, message));
    }
    return widget.child;
  }

  void _showSnackbar(
    BuildContext context,
    WidgetRef ref,
    NotificationMessage notification,
  ) {
    if (entry != null) {
      entry?.remove();
      entry = null;
      if (context.mounted) {
        setState(() {});
      }
      return;
    }
    if (!context.mounted) {
      return;
    }

    entry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        top: MediaQuery.of(context).size.height *
            0.8, // Adjust position as needed
        width: MediaQuery.of(context).size.width,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color.fromARGB(0xFF, 0, 0, 0),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  notification.message,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: const Color.fromARGB(0xFF, 0, 0, 0)),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Insert the overlay entry above the current overlay entries (dialogs)
    Overlay.of(context).insert(entry!);
    ref.read(notificationMessageProvider.notifier).pop();
    // Remove the overlay entry after a certain duration
    Future.delayed(const Duration(seconds: 2), () {
      entry?.remove();
      entry = null;
    });
  }
}
