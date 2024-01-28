import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppTheme extends ConsumerWidget {
  const AppTheme({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.copyWith(
              bodyLarge: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
      ),
      child: child,
    );
  }
}

class UpsertCollectionFormTheme extends ConsumerWidget {
  const UpsertCollectionFormTheme({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = MaterialStateProperty.all(
      const Color.fromARGB(0, 0, 0, 0),
    );

    final themeData = Theme.of(context).copyWith(
      searchBarTheme: SearchBarThemeData(
        textStyle: MaterialStateProperty.all(
          const TextStyle(color: Colors.blue),
        ),
        textCapitalization: TextCapitalization.words,
        backgroundColor: color,
        shadowColor: color,
        surfaceTintColor: color,
        overlayColor: color,
        shape: MaterialStateProperty.all(
          const ContinuousRectangleBorder(),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(4),
      ),
    );
    return Theme(
      data: themeData,
      child: child,
    );
  }
}
