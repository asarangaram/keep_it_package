import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BasicPageService extends StatelessWidget {
  const BasicPageService._({
    required this.message,
    required this.navBar,
    super.key,
  });
  // Use with Page
  factory BasicPageService.withNavBar({required dynamic message}) {
    return BasicPageService._(
      message: message,
      navBar: true,
      key: ValueKey('$message ${true}'),
    );
  }
  // Use as Widget
  factory BasicPageService.message({required dynamic message}) {
    return BasicPageService._(
      message: message,
      navBar: false,
      key: ValueKey('$message ${false}'),
    );
  }
  final dynamic message;
  final bool navBar;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: (message is String)
                    ? CLText.large(
                        message as String,
                      )
                    : (message is Widget)
                        ? message as Widget
                        : throw Exception('must be either widget or a string'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (CLPopScreen.canPop(context))
                    CLPopScreen.onTap(
                      child: CLButtonIcon.large(
                        clIcons.pagePop,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  CLButtonIcon.large(
                    clIcons.navigateHome,
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => context.go('/'),
                  ),
                ].map((e) => Expanded(child: Center(child: e))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
    /* 
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: CLText.large(
          message,
        ),
      ),
    ); */
  }
}
