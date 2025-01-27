import 'package:flutter/material.dart';

class AppTheme extends StatelessWidget {
  const AppTheme({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.copyWith(
              bodyLarge: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
        appBarTheme: Theme.of(context).appBarTheme.copyWith(
              shadowColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              centerTitle: false,
            ),
        /* inputDecorationTheme: InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          disabledBorder: CLTextField.buildOutlineInputBorder(context),
          enabledBorder: CLTextField.buildOutlineInputBorder(context),
          focusedBorder: CLTextField.buildOutlineInputBorder(context, width: 2),
          errorBorder: CLTextField.buildOutlineInputBorder(context),
          focusedErrorBorder:
              CLTextField.buildOutlineInputBorder(context, width: 2),
          errorStyle: CLTextField.buildTextStyle(context),
          floatingLabelStyle: CLTextField.buildTextStyle(context),
        ), */
      ),
      child: child,
    );
  }
}
