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
    final themeData = Theme.of(context).copyWith(
      searchBarTheme: SearchBarThemeData(
        textStyle: MaterialStateProperty.all(
          const TextStyle(color: Colors.blue),
        ),
        textCapitalization: TextCapitalization.words,
        backgroundColor: MaterialStateProperty.all(
          const Color.fromARGB(0, 238, 228, 182),
        ),
        shadowColor: MaterialStateProperty.all(
          const Color.fromARGB(0, 238, 228, 182),
        ),
        surfaceTintColor: MaterialStateProperty.all(
          const Color.fromARGB(0, 238, 228, 182),
        ),
        overlayColor: MaterialStateProperty.all(
          const Color.fromARGB(0, 238, 228, 182),
        ),
        shape: MaterialStateProperty.all(
          const ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
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
