import 'package:flutter/material.dart';

import '../basics/cl_text_field.dart';

class CLFullscreenBox extends StatelessWidget {
  const CLFullscreenBox({
    required Widget child,
    super.key,
    this.useSafeArea = false,
    this.backgroundColor,
    this.hasBorder = false,
  })  
  // ignore: prefer_initializing_formals
  : child = child,
        isEnhanced = false,
        children = null,
        currentIndex = null,
        onPageChange = null;
  const CLFullscreenBox.navBar({
    required Map<BottomNavigationBarItem, Widget> navMap,
    required int currentIndex,
    super.key,
    this.onPageChange,
    this.useSafeArea = false,
    this.backgroundColor,
    this.hasBorder = false,
  })  : isEnhanced = true,
        child = null,
        children = navMap,
        // ignore: prefer_initializing_formals
        currentIndex = currentIndex;
  final Widget? child;
  final bool useSafeArea;
  final Color? backgroundColor;
  final bool hasBorder;
  final bool isEnhanced;
  final Map<BottomNavigationBarItem, Widget>? children;
  final int? currentIndex;
  final void Function(int index)? onPageChange;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context).copyWith(
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        disabledBorder: CLTextField.buildOutlineInputBorder(context),
        enabledBorder: CLTextField.buildOutlineInputBorder(context),
        focusedBorder: CLTextField.buildOutlineInputBorder(context, width: 2),
        errorBorder: CLTextField.buildOutlineInputBorder(context),
        focusedErrorBorder:
            CLTextField.buildOutlineInputBorder(context, width: 2),
        errorStyle: CLTextField.buildTextStyle(context),
        floatingLabelStyle: CLTextField.buildTextStyle(context),
      ),
    );
    if (isEnhanced) {
      return Theme(
        data: themeData,
        child: CLFullscreenBoxEnhanced(
          navMap: children!,
          useSafeArea: useSafeArea,
          backgroundColor: backgroundColor,
          hasBorder: hasBorder,
          currentIndex: currentIndex!,
          onPageChange: onPageChange,
        ),
      );
    }
    return Theme(
      data: themeData,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          top: useSafeArea,
          left: useSafeArea,
          right: useSafeArea,
          bottom: useSafeArea,
          child: ClipRect(
            clipBehavior: Clip.antiAlias,
            child: ScaffoldBorder(
              hasBorder: hasBorder,
              child: LayoutBuilder(
                builder: (context, constraints) => child!,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CLFullscreenBoxEnhanced extends StatefulWidget {
  const CLFullscreenBoxEnhanced({
    required this.navMap,
    required this.currentIndex,
    super.key,
    this.useSafeArea = false,
    this.backgroundColor,
    this.hasBorder = false,
    this.onPageChange,
  });
  final bool useSafeArea;
  final Color? backgroundColor;
  final bool hasBorder;
  final int currentIndex;
  final void Function(int index)? onPageChange;

  final Map<BottomNavigationBarItem, Widget> navMap;

  @override
  State<StatefulWidget> createState() => _CLFullscreenBoxEnhancedState();
}

class _CLFullscreenBoxEnhancedState extends State<CLFullscreenBoxEnhanced> {
  late int currentIndex;
  @override
  void initState() {
    currentIndex = widget.currentIndex;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    currentIndex = widget.currentIndex;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        items: widget.navMap.keys.toList(),
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
          widget.onPageChange?.call(currentIndex);
        },
      ),
      body: SafeArea(
        top: widget.useSafeArea,
        left: widget.useSafeArea,
        right: widget.useSafeArea,
        bottom: widget.useSafeArea,
        child: ClipRect(
          clipBehavior: Clip.antiAlias,
          child: ScaffoldBorder(
            hasBorder: widget.hasBorder,
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  widget.navMap.values.toList()[currentIndex],
            ),
          ),
        ),
      ),
    );
  }
}

class ScaffoldBorder extends StatelessWidget {
  const ScaffoldBorder({
    required this.hasBorder,
    required this.child,
    super.key,
  });
  final bool hasBorder;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (!hasBorder) return child;
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: child,
    );
  }
}
